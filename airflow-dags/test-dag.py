import datetime

from airflow.sdk import DAG
from airflow.providers.standard.operators.empty import EmptyOperator

# Dummy line
with DAG(
    dag_id="test-dag",
    start_date=datetime.datetime(2025, 5, 11),
    schedule="*/2 * * * *",
    catchup = False
):
    EmptyOperator(task_id="task")
