# cdc-etl
ETL for CDC using Debezium, Kafka, Postgres, Docker

# Project Steps & Commands

* Running the docker compose using: docker compose up -d
* pip install psycopg2-binary
* pip install faker
* Writing the main.py
* Running the python scrpit using python3 main.py
* Adding the pgadmin to the docker-compose.yml
* Running the pgadmin using localhost:5050
* Create a connector using the debezium through localhost:8080
* Control Center: http://localhost:9021/clusters/MS0IWSTnSOu8gAvUNue1NQ/overview
* Going to topics, check the messages to see the log.
* Now we need to fix the amount and then look back at the log.
* update transactions set amount = amount + 100 where transaction_id = 'a485b65e-6cbf-4649-8f42-54b9be6cc218';
* The problem still exists, we need to fix it. (ALTER TABLE transactions REPLICA IDENTITY FULL;) Any actions made to the db will be replicated as before and after. (Now we have before and after in the payload but amount is still not fixed)
* We need to change the connector value to fix the amount decimal conversion in debezium.
Using an API call to the debezium: (Run the following command in the debezium container)
curl -X PUT -H 'Content-Type: application/json' localhost:8083/connectors/pgsql_cdc_connector/config \
--data '
{
  "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
  "topic.prefix": "cdc",
  "database.user": "postgres",
  "database.dbname": "financial_db",
  "database.hostname": "postgres",
  "database.password": "postgres",
  "plugin.name": "pgoutput",
  "decimal.handling.mode":"string"
}
'


I got: 

{"name":"pgsql_cdc_connector","config":{"connector.class":"io.debezium.connector.postgresql.PostgresConnector","topic.prefix":"cdc","database.user":"postgres","database.dbname":"financial_db","database.hostname":"postgres","database.password":"postgres","plugin.name":"pgoutput","decimal.handling.mode":"string","name":"pgsql_cdc_connector"},"tasks":[{"connector":"pgsql_cdc_connector","task":0}],"type":"source"}


OK

* Now inserting, updating, etc is triggered at debezium.
* Now we need to add the ability to track who and when the change has been made.
* Adding two columns for modified_by and modified_with.
* Create a function:
CREATE OR REPLACE FUNCTION record_change_user()
RETURNS TRIGGER AS $$
BEGIN
NEW.modified_by := current_user;
NEW.modified_at := CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
* Now we need to assign that function to transactions table.

CREATE TRIGGER trigger_record_user_update
BEFORE UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION record_change_user();

* Now we need to track what columns are changed, and what is the old and new values.
* We will drop the previous trigger (DROP TRIGGER trigger_record_user_update on transactions;)
* We will create a function to track the changed columns and old and new values.

CREATE OR REPLACE FUNCTION record_changed_columns()
RETURNS TRIGGER AS $$
DECLARE
change_details JSONB;
BEGIN
change_details := '{}'::JSONB; -- empty json object
if NEW.amount IS DISTINCT FROM OLD.amount THEN
change_details := jsonb_set(change_details, '{amount}', json_build_object('old', OLD.amount, 'new', NEW.amount), true);
END IF;
-- adding the user and timestmap
change_details := change_details || jsonb_build_object('modified_by', current_user, 'modified_at', now());
-- update the change_info column
-- update both user and timestamp columns invidually as well
NEW.modified_by := current_user;
NEW.modified_at := CURRENT_TIMESTAMP;
NEW.change_info := change_details;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION record_changed_columns()
RETURNS TRIGGER AS $$
DECLARE
    change_details JSONB;
BEGIN
    change_details := '{}'::JSONB; -- empty json object
    
    -- Check if the amount has changed
    IF NEW.amount IS DISTINCT FROM OLD.amount THEN
        -- Add the old and new amount to the change_details JSONB
        change_details := change_details || jsonb_build_object(
            'amount', jsonb_build_object(
                'old', OLD.amount,
                'new', NEW.amount
            )
        );
    END IF;

    -- Add the user and timestamp to change_details
    change_details := change_details || jsonb_build_object(
        'modified_by', current_user,
        'modified_at', now()
    );

    -- Update the new row with modified_by, modified_at, and change_info
    NEW.modified_by := current_user;
    NEW.modified_at := CURRENT_TIMESTAMP;
    NEW.change_info := change_details;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



* Associate the function with the table transcations

ALTER TABLE transactions ADD COLUMN change_info JSONB;

DROP TRIGGER IF EXISTS trigger_record_change_information ON transactions;

CREATE TRIGGER trigger_record_change_information
BEFORE UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION record_changed_columns();

update transactions set amount = amount + 1000 where transaction_id = '30df12d8-f2ae-42c3-8e30-44d4befdc4e1';