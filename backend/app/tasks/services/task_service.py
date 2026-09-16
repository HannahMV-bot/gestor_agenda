from bson import ObjectId
from datetime import datetime

from app.database import tasks_collection
from app.tasks.models.task import task_model


def create_task(
    user_id: str,
    title: str,
    description: str,
    date: str,
    time: str,
    status: str,
    priority: str,
):
    new_task = task_model(
        user_id=user_id,
        title=title,
        description=description,
        date=date,
        time=time,
        status=status,
        priority=priority,
    )

    result = tasks_collection.insert_one(
        new_task
    )

    return str(result.inserted_id)


def get_tasks(user_id: str):
    tasks = tasks_collection.find(
        {
            "user_id": user_id
        }
    ).sort(
        [
            ("date", 1),
            ("time", 1),
        ]
    )

    result = []

    for task in tasks:
        result.append(
            {
                "id": str(task["_id"]),
                "user_id":
                    task["user_id"],
                "title":
                    task["title"],
                "description":
                    task["description"],
                "date":
                    task["date"],
                "time":
                    task["time"],
                "status":
                    task["status"],
                "priority":
                    task["priority"],
            }
        )

    return result


def get_task(
    user_id: str,
    task_id: str,
):
    if not ObjectId.is_valid(
        task_id
    ):
        return None

    task = tasks_collection.find_one(
        {
            "_id":
                ObjectId(task_id),
            "user_id":
                user_id,
        }
    )

    if not task:
        return None

    return {
        "id":
            str(task["_id"]),
        "user_id":
            task["user_id"],
        "title":
            task["title"],
        "description":
            task["description"],
        "date":
            task["date"],
        "time":
            task["time"],
        "status":
            task["status"],
        "priority":
            task["priority"],
    }


def update_task(
    user_id: str,
    task_id: str,
    title: str,
    description: str,
    date: str,
    time: str,
    status: str,
    priority: str,
):
    if not ObjectId.is_valid(
        task_id
    ):
        return False

    result = tasks_collection.update_one(
        {
            "_id":
                ObjectId(task_id),
            "user_id":
                user_id,
        },
        {
            "$set": {
                "title":
                    title,
                "description":
                    description,
                "date":
                    date,
                "time":
                    time,
                "status":
                    status,
                "priority":
                    priority,
                "updated_at":
                    datetime.utcnow(),
            }
        },
    )

    return result.matched_count > 0


def delete_task(
    user_id: str,
    task_id: str,
):
    if not ObjectId.is_valid(
        task_id
    ):
        return False

    result = tasks_collection.delete_one(
        {
            "_id":
                ObjectId(task_id),
            "user_id":
                user_id,
        }
    )

    return result.deleted_count > 0