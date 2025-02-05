create database Assignment_mod_5_6
use Assignment_mod_5_6

select * from jomato

1) ----- Create a stored procedure to display the restaurant name, type and cuisine where the table booking is not zero

create proc usp_SPJomato
AS
(
select restaurantname, restauranttype, cuisinesType, tablebooking from jomato where tablebooking not like  0)

exec usp_SPJomato

2) ----- Create a transaction and update the cuisine type ‘Cafe’ to ‘Cafeteria’. Check the result and rollback it.

begin transaction 

update jomato set cuisinesType = 'cafeteria' where cuisinesType = 'cafe'

select * from jomato where cuisinesType = 'cafeteria'

rollback transaction

3) ----- Generate a row number column and find the top 5 areas with the highest rating of restaurants.

with top_areas
as
(
select restaurantname, area, localaddress, rating, ROW_NUMBER() over(partition by area order by rating desc) as rows
from jomato)

select restaurantname, area, localaddress, rating from top_areas 
where rows <=5

------------------or---------------------

With RestaurantRank
as
(
Select RestaurantName, area, Rating, ROW_NUMBER() Over(Order by Rating Desc) as RowNum From Jomato) 

Select RestaurantName, area, Rating From RestaurantRank  Where RowNum <= 5;

------------or------------

select top 5
DENSE_RANK () over(order by rating desc) as Rownum, RestaurantName, area, rating
from Jomato


4) ----- Use the while loop to display the 1 to 50.

Declare @count int
set @count=1
while(@count<=50)

begin
print(@count)
set @count = @count+1
end

5) ------ Write a query to Create a Top rating view to store the generated top 5 highest rating of restaurants.

create view vw_top5
as
with top_areas
as
(
select restaurantname, area, localaddress, rating, ROW_NUMBER() over(partition by area order by rating desc) as rows
from jomato)

select restaurantname, area, localaddress, rating from top_areas 
where rows <=5

select * from vw_top5

------or---------

create view vw_top5ratings
as
With RestaurantRank
as
(
Select RestaurantName, area, Rating, ROW_NUMBER() Over(Order by Rating Desc) as RowNum From Jomato) 

Select RestaurantName, area, Rating From RestaurantRank  Where RowNum <= 5;

select * from vw_top5ratings

----------or----------

create view vw_ratingstop5
as
select top 5
DENSE_RANK () over(order by rating desc) as Rownum, RestaurantName, area
from Jomato

select * from vw_ratingstop5


6) -------- Write a trigger that sends an email notification to the restaurant owner whenever a new record is inserted

create trigger new_addition
on jomato
for update
as
begin
Declare @restaurant nvarchar(35)
declare @email_id nvarchar(25)

select @restaurant = restaurantname
from inserted 

if @restaurant is not null AND @email_id is not null
begin
declare @subject nvarchar(255) = 'New Restaurant Added' 
declare @body nvarchar(max) = 'A new restaurant (' + @restaurant + ') has been added'

EXEC msdb.dbo.sp_send_dbmail  
@profile_name = 'New_Name',
@recipients = @email_id, 
@subject = @subject,
@body = @body

end 

end

-------------or------------

Create trigger 	Email_Notify
on jomato
after insert
as
begin

EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'New_name',
@recipients = 'New_name@gmail.com',
@subject = 'New Record Inserted.',
@body = 'A new record has been inserted.'

end
