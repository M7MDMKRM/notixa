import json
import re
from datetime import datetime, timedelta, timezone
from typing import List, Tuple
import httpx
from app.core.config import settings
from app.schemas.ai import AIExtractResponse
from app.schemas.meeting import MeetingCreate
from app.schemas.transaction import TransactionCreate


class AIService:
    @staticmethod
    async def extract_from_voice_note(raw_text: str) -> AIExtractResponse:
        trimmed = raw_text.trim() if hasattr(raw_text, "trim") else raw_text.strip()
        if not trimmed:
            return AIExtractResponse(
                raw_text=raw_text,
                transactions=[],
                meetings=[],
                total_spent=0.0,
                total_received=0.0,
                net_remaining=0.0,
            )

        # 1. Try Google Gemini Flash API via async httpx
        try:
            gemini_res = await AIService._call_gemini(trimmed)
            if gemini_res and (gemini_res.transactions or gemini_res.meetings):
                return gemini_res
        except Exception:
            pass

        # 2. Local Fallback Egyptian Dialect NLP Parser
        return AIService._local_nlp_fallback(trimmed)

    @staticmethod
    async def _call_gemini(text: str) -> AIExtractResponse | None:
        url = (
            f"https://generativelanguage.googleapis.com/v1beta/models/"
            f"{settings.GEMINI_MODEL}:generateContent?key={settings.GEMINI_API_KEY}"
        )

        system_prompt = f"""
أنت خبير ومساعد مالي ذكي لتطبيق مصاريف مصري (NEXA).
المستخدم سجل هذه الملاحظة الصوتية:
"{text}"

المطلوب:
استخراج جميع المعاملات المالية (سواء رصيد أولي/مستلم أو مصروفات) وأي مواعيد أو اجتماعات بدقة متناهية.
القواعد الصارمة:
1. "received" للمبالغ المستلمة أو الرصيد الأولي الذي كان مع المستخدم (مثل "كان معايا 200").
2. "spent" للمصروفات المدفوعة.
3. إذا ذكر المستخدم عدة مشتريات مستقلة لها نفس المبلغ (مثل مياه بـ 10 وعصير بـ 10)، اجعل كل واحد بنداً مستقلاً ولا تدمجهم إطلاقاً.
4. إذا ذكر المستخدم مبلغا مجملا ثم خصصه (مثل "صرفت 70 على الأكل فأكلت بـ 70")، اعتمد البند المخصص فقط ولا تكرر الـ 70.
5. إذا راجع المستخدم نفسه وصحح رقماً (مثل "صرفت 50 لا معلش 60")، اعتمد الرقم الأخير المصحح.

التصنيفات المتاحة:
- "رصيد أولي / مستلم"
- "طعام ومشروبات (Food & Drinks)"
- "مواصلات وتنقل (Transportation)"
- "شحن وفواتير (Bills & Recharge)"
- "تسوق ومشتريات (Shopping)"
- "عام ومصروفات"

أجب بصيغة JSON فقط بهذا الشكل:
{{
  "transactions": [
    {{
      "amount": 200.0,
      "type": "received",
      "status": "Done",
      "category": "رصيد أولي / مستلم",
      "currency": "EGP",
      "note": "رصيد أولي كان معايا"
    }}
  ],
  "meetings": []
}}
"""

        body = {
            "contents": [{"parts": [{"text": system_prompt}]}],
            "generationConfig": {"responseMimeType": "application/json"},
        }

        async with httpx.AsyncClient(timeout=8.0) as client:
            resp = await client.post(url, json=body)
            if resp.status_code != 200:
                return None

            data = resp.json()
            candidates = data.get("candidates", [])
            if not candidates:
                return None

            raw_json = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "")
            if not raw_json:
                return None

            # Clean markdown code fences if present
            cleaned = raw_json.strip()
            if cleaned.startswith("```json"):
                cleaned = cleaned[7:]
            elif cleaned.startswith("```"):
                cleaned = cleaned[3:]
            if cleaned.endswith("```"):
                cleaned = cleaned[:-3]
            cleaned = cleaned.strip()

            parsed = json.loads(cleaned)

            transactions = []
            total_spent = 0.0
            total_received = 0.0

            for item in parsed.get("transactions", []):
                amt = float(item.get("amount", 0.0))
                if amt <= 0:
                    continue
                type_ = str(item.get("type", "spent")).lower()
                is_income = type_ in ["received", "income"]
                cat = item.get("category") or ("رصيد أولي / مستلم" if is_income else "عام ومصروفات")
                note_str = item.get("note") or ("رصيد أولي نزل به" if is_income else "مصروف")

                if is_income:
                    total_received += amt
                else:
                    total_spent += amt

                transactions.append(
                    TransactionCreate(
                        amount=amt,
                        type="received" if is_income else "spent",
                        status="Done",
                        category=cat,
                        currency=item.get("currency", "EGP"),
                        note=note_str,
                        date=datetime.now(timezone.utc),
                    )
                )

            meetings = []
            for item in parsed.get("meetings", []):
                title = item.get("title", "موعد مسجل")
                desc = item.get("description", text)
                start_dt = datetime.now(timezone.utc) + timedelta(hours=2)
                if item.get("startTime"):
                    try:
                        start_dt = datetime.fromisoformat(item["startTime"])
                    except Exception:
                        pass

                meetings.append(
                    MeetingCreate(
                        title=title,
                        description=desc,
                        start_time=start_dt,
                        end_time=start_dt + timedelta(hours=1),
                        repetition="none",
                        has_alarm=True,
                    )
                )

            net_remaining = total_received - total_spent if total_received > 0 else 0.0

            return AIExtractResponse(
                raw_text=text,
                transactions=transactions,
                meetings=meetings,
                total_spent=round(total_spent, 2),
                total_received=round(total_received, 2),
                net_remaining=round(net_remaining, 2),
            )

    @staticmethod
    def _local_nlp_fallback(text: str) -> AIExtractResponse:
        # Normalize Arabic numerals
        arabic_indic = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        standard = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        normalized = text
        for i in range(10):
            normalized = normalized.replace(arabic_indic[i], standard[i])

        pattern = re.compile(
            r"(\d+(?:\.\d+)?)\s*(?:جنية|جنيه|ج|ج\.م|دولار|dollar|egp|usd|\$|ريال|sar|درهم|aed)?",
            re.IGNORECASE,
        )

        matches = list(pattern.finditer(normalized))
        transactions = []
        total_spent = 0.0
        total_received = 0.0

        for i, m in enumerate(matches):
            try:
                amt = float(m.group(1))
            except ValueError:
                continue
            if amt <= 0:
                continue

            clause_start = 0 if i == 0 else matches[i - 1].end()
            clause_end = m.end()
            raw_clause = normalized[clause_start:clause_end].strip()
            lower = raw_clause.lower()

            is_income = any(w in lower for w in ["معايا", "نزلت ب", "نزل معايا", "استلمت", "قبضت", "جالي"])
            is_food = any(w in lower for w in ["اكلت", "أكلت", "اكل", "فطرت", "غدا", "عشا", "ميه", "عصير", "شربت"])
            is_transport = any(w in lower for w in ["مواصلات", "ركبت", "تاكسي", "مترو", "بنزين"])
            is_bills = any(w in lower for w in ["شحنت", "كارت", "فك", "فكة", "رصيد", "مكالمات", "فاتورة"])

            if is_income and not (is_food or is_transport or is_bills):
                cat = "رصيد أولي / مستلم"
                note_str = "رصيد أولي نزل به"
                type_ = "received"
                total_received += amt
            elif is_food:
                cat = "طعام ومشروبات (Food & Drinks)"
                note_str = "وجبة وأكل ومشروبات"
                type_ = "spent"
                total_spent += amt
            elif is_transport:
                cat = "مواصلات وتنقل (Transportation)"
                note_str = "مواصلات وتنقلات"
                type_ = "spent"
                total_spent += amt
            elif is_bills:
                cat = "شحن وفواتير (Bills & Recharge)"
                note_str = "شحن كارت فكة ومكالمات"
                type_ = "spent"
                total_spent += amt
            else:
                cat = "عام ومصروفات"
                note_str = "مصروف"
                type_ = "spent"
                total_spent += amt

            transactions.append(
                TransactionCreate(
                    amount=amt,
                    type=type_,
                    status="Done",
                    category=cat,
                    currency="EGP",
                    note=note_str,
                    date=datetime.now(timezone.utc),
                )
            )

        net = total_received - total_spent if total_received > 0 else 0.0

        return AIExtractResponse(
            raw_text=text,
            transactions=transactions,
            meetings=[],
            total_spent=round(total_spent, 2),
            total_received=round(total_received, 2),
            net_remaining=round(net, 2),
        )
