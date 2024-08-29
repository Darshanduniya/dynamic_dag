from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.utils.dates import days_ago

default_args = {
    'start_date': days_ago(1),
}

dag_one = DAG(
    'dag_one',
    default_args=default_args,
    schedule_interval=None,
)

task1 = DummyOperator(task_id='task1', dag=dag_one)
task2 = DummyOperator(task_id='task2', dag=dag_one)
task3 = DummyOperator(task_id='task3', dag=dag_one)
task4 = DummyOperator(task_id='task4', dag=dag_one)
task5 = DummyOperator(task_id='task5', dag=dag_one)

# Trigger dag_two after task3 is complete
trigger_dag_two = TriggerDagRunOperator(
    task_id='trigger_dag_two',
    trigger_dag_id='dag_two',
    dag=dag_one,
)

task1 >> task2 >> task3 >> trigger_dag_two
trigger_dag_two >> task4 >> task5



===
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.utils.dates import days_ago

default_args = {
    'start_date': days_ago(1),
}

dag_two = DAG(
    'dag_two',
    default_args=default_args,
    schedule_interval=None,
)

task_a = DummyOperator(task_id='task_a', dag=dag_two)
task_b = DummyOperator(task_id='task_b', dag=dag_two)

# Trigger dag_one from task4 after dag_two completes
trigger_dag_one_from_task4 = TriggerDagRunOperator(
    task_id='trigger_dag_one_from_task4',
    trigger_dag_id='dag_one',
    conf={"start_task_id": "task4"},
    dag=dag_two,
)

task_a >> task_b >> trigger_dag_one_from_task4
