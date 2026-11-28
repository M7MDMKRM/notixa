import pytest
from httpx import AsyncClient
from app.main import app


@pytest.mark.asyncio
async def test_health_check():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


@pytest.mark.asyncio
async def test_root_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/")
    assert response.status_code == 200
    assert response.json()["name"] == "NEXA Backend"


@pytest.mark.asyncio
async def test_notes_crud():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        # 1. Create a personal note
        create_res = await ac.post(
            "/api/v1/notes/",
            json={"title": "ملاحظة شخصية هامة", "content": "تجربة الباك إند الجديد", "category": "شخصي"},
        )
        assert create_res.status_code == 201
        note_data = create_res.json()
        note_id = note_data["id"]
        assert note_data["title"] == "ملاحظة شخصية هامة"

        # 2. Get list of notes
        list_res = await ac.get("/api/v1/notes/")
        assert list_res.status_code == 200
        assert len(list_res.json()) >= 1

        # 3. Toggle Pin
        pin_res = await ac.patch(f"/api/v1/notes/{note_id}/pin")
        assert pin_res.status_code == 200
        assert pin_res.json()["is_pinned"] is True

        # 4. Delete note
        del_res = await ac.delete(f"/api/v1/notes/{note_id}")
        assert del_res.status_code == 204
