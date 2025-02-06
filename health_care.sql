create table appointments
	(appointment_id	int,patient_id int,doctor_id int,appointment_date date,reason text,status text);
Select * from appointments;

create table diagnoses
	(diagnosis_id int,patient_id int,doctor_id int,diagnosis_date date,diagnosis text,treatment text);
select * from diagnoses;

create table doctors
	(doctor_id int primary key,
	name text NOT NULL,
	specialization text NOT NULL,
	experience_years int NOT NULL check (experience_years > 0),
	contact_number varchar(10));
Select * from doctors;

create table medications
	(medication_id int ,
	 diagnosis_id int ,
	 medication_name text, 
	 dosage text ,
	 start_date date ,
	 end_date date)

create table patients
	(patient_id int,
     name text,
	 age int,
	 gender text,
	 address text, 
	 contact_number varchar(11));

--Inner and Equi Joins : Write a query to fetch details of all completed appointments,
						--including the patient’s name, doctor’s name, and specialization.

with  Doctor_detail as( 
select appointments.appointment_id,
	   appointments.patient_id, 
	   doctors.doctor_id, 
	   doctors.name as doctor_name, 
	   doctors.specialization as doctor_specialization, 
	   appointments.status as appointment_status
from appointments
inner join doctors
on appointments.doctor_id=doctors.doctor_id
where appointments.status = 'Completed'
)
Select  
	   Doctor_detail.appointment_id,
	   Doctor_detail.patient_id, 
	   patients.name as Patient_name,
	   Doctor_detail.doctor_id, 
	   Doctor_detail.doctor_name, 
	   Doctor_detail.doctor_specialization, 
	   Doctor_detail.appointment_status
from 
	   Doctor_detail
inner join 
	   patients
on
	   Doctor_detail.patient_id=patients.patient_id;

-- Left Join with Null Handling
-- Task: Retrieve all patients who have never had an appointment. Include their name, contact details, and address in the output.

with data as(select * from patients
left join  appointments
on patients.patient_id=appointments.patient_id 
where patients.name is null)
select 
	data.name,
	data.contact_number,
	data.address
from data
--Right Join and Aggregate Functions
--Task: Find the total number of diagnoses for each doctor, including doctors who haven’t diagnosed any patients. 
--      Display the doctor’s name, specialization, and total diagnoses.


with data as(
select diagnoses.diagnosis_id,doctors.doctor_id,doctors.name,doctors.specialization from diagnoses
right join doctors
on diagnoses.doctor_id=doctors.doctor_id
)
select data.name as Doctor_name,
data.specialization as Doctor_specialization, 
count(data.doctor_id) as Total_diagnoses
from data 
group by data.name, data.specialization
order by Total_diagnoses DESC;


--Full Join for Overlapping Data
--Task: Write a query to identify mismatches between the appointments and diagnoses tables. 
--Include all appointments and diagnoses with their corresponding patient and doctor details.

Select appointments.appointment_id,diagnoses.diagnosis_id, appointments.doctor_id,
	doctors.name as doctor_name, doctors.specialization as doctor_specialization,diagnoses.patient_id,
	patients.name as patient_name, patients.contact_number as patient_contact_number 
	from appointments
full join diagnoses
on appointments.patient_id=diagnoses.patient_id
left join patients
on patients.patient_id= diagnoses.patient_id
left join doctors
on doctors.doctor_id=diagnoses.doctor_id
where appointment_id is null;
	
--Window Functions (Ranking and Aggregation)
--Task: For each doctor, rank their patients based on the number of appointments in descending order.

with data as(
select appointments.appointment_id,doctors.doctor_id,doctors.name as Doctor_name,
appointments.patient_id,patients.name from appointments
join doctors
on appointments.doctor_id=doctors.doctor_id
join  patients
on appointments.patient_id=patients.patient_id
)
select doctor_id,doctor_name,
		count(data.patient_id) as total,
		rank() over (order by count(data.patient_id) desc) as rank
from data
group by doctor_id,doctor_name
order by total  desc;


--Conditional Expressions
--Task: Write a query to categorize patients by age group (e.g., 18-30, 31-50, 51+). Count the number of patients in each age group.

select 
case 
	when age between 1 and 10 then '1-10'
	when age between 11 and 20 then '11-20'
	when age between 21 and 30 then '21-30'
	when age between 31 and 40 then '31-40'
	when age between 41 and 50 then '41-50'
	when age between 51 and 60 then '51-60'
	when age between 61 and 70 then '61-70'
	when age between 71 and 80 then '71-80'
	when age between 81 and 90 then '81-90' 
	when age >91 then '90+'
	else 'unknown'
end as age_group,
count(*) as total_patients
from patients
group by age_group 
order by age_group;

--Numeric and String Functions
--Task: Retrieve a list of patients whose contact numbers end with "1234" and display their names in uppercase.
select 
	patient_id,
	upper(name),
	age,
	gender,
	address,
	contact_number
from patients
where contact_number like '%123' ;

--Subqueries for Filtering
--Task: Find patients who have only been prescribed "Insulin" in any of their diagnoses.

select * from diagnoses
where diagnosis = 'Insulin';

--Date and Time Functions
--Task: Calculate the average duration (in days) for which medications are prescribed for each diagnosis.

select 
	appointments.patient_id,
	appointments.appointment_date,
	diagnoses.diagnosis_date,
	diagnoses.diagnosis,
	diagnoses.diagnosis_date - appointments.appointment_date AS diff_date from appointments
full join diagnoses
on appointments.patient_id=diagnoses.patient_id 
where appointments.patient_id is not null

--Complex Joins and Aggregation
--Task: Write a query to identify the doctor who has attended the most unique patients.
--Include the doctor’s name, specialization, and the count of unique patients.
with data as(
select 
	appointments.doctor_id,
	doctors.name as doctor_name,doctors.specialization as doctor_specilization, 
	appointments.patient_id, patients.name from appointments
join doctors
on appointments.doctor_id=doctors.doctor_id
join patients
on appointments.patient_id=patients.patient_id
GROUP BY patients.name, appointments.doctor_id, doctors.name, doctors.specialization, appointments.patient_id)
select 
	data.doctor_id, data.Doctor_name,
	data.doctor_specilization ,
	count(data.patient_id) as Unique_patients
from 
	data
group by
	data.doctor_id, data.doctor_name,
	data.doctor_specilization ;
 