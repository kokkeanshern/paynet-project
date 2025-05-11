from airflow import DAG
from airflow.operators.empty import EmptyOperator
from datetime import datetime

with DAG(
    dag_id="test-dag",
    start_date=datetime(2025, 5, 11),
    schedule="*/2 * * * *",  # OK for 2.8+
    catchup=False,
) as dag:
    EmptyOperator(task_id="task")
