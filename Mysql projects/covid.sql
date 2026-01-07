  -- create database --
  
create database covid_vax_management ;
use covid_vax_management;

  -- create the patients table --
  
  create table patients (
  patient_id int auto_increment primary key,
  first_name varchar(50) unique not null,
  last_name varchar(50) unique not null,
  dob date,
  address varchar (255),
  contact_number varchar(255)
  );
  
  
  
  -- create the vaccine stock table --
  
  create table vaccine_stock (
  vaccine_id int auto_increment primary key,
  vaccine_name varchar(50) unique,
  stock_count int default 0
  );
  
  
  -- create the vaccine doses table record administered doses --
  
  create table vaccine_doses (
  dose_id int auto_increment primary key,
  patient_id int,
  vaccine_id int,
  dose_number int,
  administration_date date,
  foreign key (patient_id) references patients (patient_id),
  foreign key (vaccine_id) references vaccine_stock (vaccine_id)
  );
  
   -- seed initial vaccine stock data --
   
   insert into vaccine_stock ( vaccine_name, stock_count) values 
   ('Pfizar',1000),
   ('Moderna',1500),
   ('AstraZeneca',800);
   
   -- Procedures 
   -- stored procedures are used to centralize and reuse complex logic .
   -- procedure to register a new patient .
   -- this procedure inserts a new patient into the patients table.
   
   
   delimiter //
   create procedure registerPatient(
   in P_first_name varchar(50) ,
   in p_last_name  varchar(50) ,
   in P_dob date,
   in p_address varchar(255),
   in p_contact_number varchar (15)
   )
   begin 
     insert into patients (first_name, last_name, dob , address , contact_number )
     values (p_first_name , p_last_name, p_dob , p_address , p_contact_number);
   end //
   delimiter ;

   -- procedure to administer a vaccine dose 
   -- this procedure handles the  administration of a vaccine dose, varchar decrementing the stock and recording the dose.
   
   delimiter //
   create procedure administerVaccineDose(
   in p_patient_id int,
   in p_vaccine_name varchar(50),
   in p_dose_number int
   )
     begin 
        declare v_vaccine_id int ;
      
      -- find the vaccine_id from the name 
        select vaccine_id into v_vaccine_id from vaccine_stock  where vaccine_name = p_vaccine_name ;
	
          -- check for sufficient stock before proceeding 
          if (select stock_count from vaccine_stock where vaccine_id = v_vaccine_id) > 0 then 
    
             -- record the vaccine dose
             insert into vaccine_doses (patient_id, vaccine_id, dose_number, administration_date)
             values (p_patient_id,v_vaccine_id , p_dose_number , curdate() );
    
             -- update the stock ( this  will be handled by a trigger, see below)
	         update vaccine_stock set  stock_count = stock_count - 1 where vaccine_id = v_vaccine_id ;
             
           else
              signal sqlstate '45000' set message_text = 'error : Insufficient vaccine stock.';
		   end if ;
	end //
    delimiter ;
    
    
    -- triggers 
    -- triggers are automatically executed in response to specific events on a table , like insert , update , or delete.
    -- triggers to update vaccine stock 
    
    delimiter //
    create  trigger AfterVaccineDoseInsert 
    after insert on vaccine_doses 
    for each row 
    begin
        update vaccine_stock
        set stock_count = stock_count - 1
        where vaccine_id = new.vaccine_id ;
	end //
    delimiter ;
    
    
    -- triggers to prevent double vaccination 
    --  triggers prevents a patient fro receiving the same dose number twice.
    
    delimiter //
    create trigger BeforeVaccineDoseInsert
    before insert on vaccine_doses
    for each row
    begin
        declare existing_dose int ;
        select count(*) into existing_dose
        from vaccine_doses
        where patient_id = new.patient_id and dose_number = new.dose_number;
        
        if existing_dose > 0 then 
             signal sqlstate '45000'
             set message_text = 'error : this patient has already  received this dose number.' ;
	    end if ;
	end //
    delimiter ;
    
    
    -- how to use the project 
    -- run the schema and data : execute the create table and  insert statements to set up the databases .
    -- define the procedures and  triggers : execute the create procedure and create trigger blocks to add the application logic.
    -- use the procedures : call the procedures to interact with the database.
    -- example usage 
    
    -- register a new patient
    call registerpatient('John', 'Doe' , '1990-05-15' , '123 main St' , '555-1234');
    call registerpatient(('Emily', 'Smith', '1985-03-12', '742 Evergreen Terrace', '555-1023'),
                          ('Liam', 'Johnson', '1992-11-23', '123 Oak Street', '555-8921'),
('Olivia', 'Williams', '1979-07-30', '456 Pine Avenue', '555-3245'),
('Noah', 'Brown', '2001-04-18', '789 Maple Drive', '555-7789'),
('Ava', 'Jones', '1995-12-03', '321 Birch Road', '555-5567'),
('William', 'Garcia', '1988-06-25', '654 Cedar Lane', '555-8876'),
('Sophia', 'Martinez', '1993-09-14', '987 Walnut Blvd', '555-4432'),
('James', 'Rodriguez', '1980-02-07', '111 Cherry St', '555-6654'),
('Isabella', 'Hernandez', '1998-10-29', '222 Spruce Ct', '555-9012'),
('Benjamin', 'Lopez', '1975-08-15', '333 Ash Way', '555-3789'));


    
    -- administer the first dose of pfizer to john doe (assuming john doe is patient id  1)
    call administerVaccineDose( 1, 'Pfizar' , 1);
    
    -- administer the second dose of pfizar (this should work)
    call administerVaccineDose(1, 'Pfizar', 2);
    
    -- attempt to administer the first dose again (this should fail due to trigger)
    call administerVaccineDose (1, 'Pfizar' ,1);
    
    
    select * from patients;
select * from vaccine_stock;
select * from vaccine_doses;
    
     
   select * from patients;