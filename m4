from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.python import BranchPythonOperator
from airflow.utils.dates import days_ago
import time

# Default args
default_args = {
    'start_date': days_ago(1),
}

# Define dag_one
with DAG('dag_one', default_args=default_args, schedule_interval=None) as dag_one:

    task1 = DummyOperator(task_id='task1')
    task2 = DummyOperator(task_id='task2')
    
    # Delay task for 1 minute
    delay_task = PythonOperator(
        task_id='delay_task',
        python_callable=lambda: time.sleep(60)
    )
    
    task3 = DummyOperator(task_id='task3')
    
    # Trigger dag_two
    trigger_dag_two = TriggerDagRunOperator(
        task_id='trigger_dag_two',
        trigger_dag_id='dag_two',  # Name of the DAG to trigger
        wait_for_completion=True,  # Wait for dag_two to complete before continuing
    )
    
    task4 = DummyOperator(task_id='task4')
    task5 = DummyOperator(task_id='task5')

    task1 >> task2 >> delay_task >> task3 >> trigger_dag_two >> task4 >> task5

# Define dag_two
with DAG('dag_two', default_args=default_args, schedule_interval=None) as dag_two:

    task_a = DummyOperator(task_id='task_a')
    task_b = DummyOperator(task_id='task_b')
    
    # Trigger dag_one from task4
    trigger_dag_one_from_task4 = TriggerDagRunOperator(
        task_id='trigger_dag_one_from_task4',
        trigger_dag_id='dag_one',  # Name of the DAG to trigger
        execution_date='{{ execution_date }}',  # Use the same execution date
        wait_for_completion=False,
        conf={"start_task": "task4"}  # Send the start task information
    )
    
    task_a >> task_b >> trigger_dag_one_from_task4
