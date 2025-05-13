import datetime
from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator
from pathlib import Path

DAG_ID = Path(__file__).stem
# t
with DAG(
    dag_id=DAG_ID,
    start_date=datetime.datetime(2023, 1, 1),
    schedule="*/2 * * * *",
    catchup=False,
    tags=["kkok"],
) as dag:
    task_1 = EmptyOperator(
        task_id="my_task",
    )
