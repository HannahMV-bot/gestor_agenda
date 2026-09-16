from datetime import datetime


def task_model(
    user_id: str,
    title: str,
    description: str,
    date: str,
    time: str,
    status: str,
    priority: str,
):
    return {
        "user_id": user_id,
        "title": title,
        "description": description,
        "date": date,
        "time": time,
        "status": status,
        "priority": priority,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }