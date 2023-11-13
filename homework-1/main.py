"""Скрипт для заполнения данными таблиц в БД Postgres."""

import psycopg2
import os
import csv

# Пароль пользователя Postgres
POSTGRES_PASS = os.getenv("POSTGRES_PASS")

# Конфиг для валидации аргументов сущности каждой таблицы
table_config = {
    "employees": {"employee_id": int, "first_name": str, "last_name": str, "title": str,
                  "birth_date": str,
                  "notes": str},
    "customers": {"customer_id": str, "company_name": str, "contact_name": str},
    "orders": {"order_id": int, "customer_id": str, "employee_id": int, "order_date": str,
               "ship_city": str}
}


def get_data_for_db(path_to_csv: str, config_dict: dict) -> list:
    """Возвращает данные из файла csv"""
    all_data = []
    try:
        with open(path_to_csv, 'rt', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                item_list = []

                for k, v in row.items():
                    item_ = config_dict[k](v)
                    item_list.append(item_)

                item_tuple = tuple(item_list)

                all_data.append(item_tuple)

    except FileNotFoundError:
        raise FileNotFoundError('Отсутствует файл csv')

    return all_data


def fill_table_data(table_name: str, values_template: str, csv_data: list) -> None:
    """Заполняет таблицу БД полученными данными csv_data"""
    try:
        with psycopg2.connect(
                host="localhost",
                database="north",
                user="postgres",
                password=POSTGRES_PASS
        ) as conn:
            with conn.cursor() as cur:
                cur.executemany(f"INSERT INTO {table_name} VALUES {values_template}", csv_data)
    finally:
        conn.close()


if __name__ == "__main__":
    fill_table_data('employees', '(%s, %s, %s, %s, %s, %s)',
                    get_data_for_db('north_data/employees_data.csv', table_config["employees"]))
    fill_table_data('customers', '(%s, %s, %s)',
                    get_data_for_db('north_data/customers_data.csv', table_config["customers"]))
    fill_table_data('orders', '(%s, %s, %s, %s, %s)',
                    get_data_for_db('north_data/orders_data.csv', table_config["orders"]))
