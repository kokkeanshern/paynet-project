from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def hello_world():
    print("Hello from Airflow!")

with DAG(
    dag_id="safe_test_dag",
    start_date=datetime(2025, 5, 11),
    schedule="*/1 * * * *",  # Every 5 minutes
    catchup=False,
    tags=["example"],
) as dag:
    hello_task = PythonOperator(
        task_id="hello_task",
        python_callable=hello_world,
    )
