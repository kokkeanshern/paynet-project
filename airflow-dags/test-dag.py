import datetime
from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator

# Dummy comment
with DAG(
    dag_id="simple_dag",
    start_date=datetime.datetime(2023, 1, 1),
    schedule="@daily",  # Example: Run daily
    catchup=False,  # Do not backfill historical runs
    tags=["kkok"],
) as dag:
    # Define a task
    task_1 = EmptyOperator(
        task_id="my_task",
    )
