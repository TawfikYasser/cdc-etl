update transactions set amount = amount + 100 where transaction_id = 'a485b65e-6cbf-4649-8f42-54b9be6cc218';

ALTER TABLE transactions REPLICA IDENTITY FULL;

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

ALTER TABLE transactions ADD COLUMN change_info JSONB;

DROP TRIGGER IF EXISTS trigger_record_change_information ON transactions;

CREATE TRIGGER trigger_record_change_information
BEFORE UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION record_changed_columns();

update transactions set amount = amount + 1000 where transaction_id = '30df12d8-f2ae-42c3-8e30-44d4befdc4e1';