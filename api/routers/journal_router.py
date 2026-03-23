from fastapi import APIRouter, Depends, HTTPException
from api.models.entry import Entry, EntryCreate
from api.services.entry_service import EntryService
from api.repositories.postgres_repository import PostgresDB

router = APIRouter()

async def get_db():
    async with PostgresDB() as db:
        yield db

@router.post("/entries")
async def create_entry(entry_data: EntryCreate, db = Depends(get_db)):
    try:
        service = EntryService(db)
        entry = Entry(work=entry_data.work, struggle=entry_data.struggle, intention=entry_data.intention)
        created = await service.create_entry(entry.model_dump())
        return {"detail": "Entry created successfully", "entry": created}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/entries")
async def get_all_entries(db = Depends(get_db)):
    try:
        service = EntryService(db)
        entries = await service.get_all_entries()
        return {"entries": entries}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/entries/{entry_id}")
async def get_entry(entry_id: str, db = Depends(get_db)):
    try:
        service = EntryService(db)
        entry = await service.get_entry(entry_id)
        if not entry:
            raise HTTPException(status_code=404, detail="Entry not found")
        return entry
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/entries/{entry_id}")
async def delete_entry(entry_id: str, db = Depends(get_db)):
    try:
        service = EntryService(db)
        entry = await service.get_entry(entry_id)
        if not entry:
            raise HTTPException(status_code=404, detail="Entry not found")
        await service.delete_entry(entry_id)
        return {"detail": "Entry deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
