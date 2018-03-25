CREATE TABLE transactions ( id serial, image text, transaction_timestamp timestamp default now(), prediction text, confirmed boolean, terminal_id integer)
CREATE TABLE terminals ( id serial, lat text, lng text)



insert into terminals (lat, lng) values
(  '1.334283' , '103.870539'),
(  '1.344283' , '103.870539'),
(  '1.354283' , '103.870539')

insert into transactions ( prediction, confirmed, terminal_id, image ) values
('bulb', true, 1, 'ABCABCABCABC'),
('bottle', true, 2, 'ABCABCABCABC'),
('mouse', true, 3, 'ABCABCABCABC'),
('bulb', true, 3, 'ABCABCABCABC'),
('bottle', true, 3, 'ABCABCABCABC')


