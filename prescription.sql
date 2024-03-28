select * from prescription;
select * from prescriber;
--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)?
--      Report the npi and the total number of claims.
select npi,
       sum(total_claim_count)as total_claims
 from prescriber 
 inner join prescription  using (npi)
 group by npi 
 order by total_claims desc
	  ;
  
-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, 
--   specialty_description, and the total number of claims.

select 
		npi
		,nppes_provider_first_name
		,nppes_provider_last_org_name
		,specialty_description,
	   sum(total_claim_count) as total_claims
from prescriber  inner join prescription using(npi)
 group by npi
		,nppes_provider_first_name
		,nppes_provider_last_org_name
		,specialty_description;


--2. 
 
   -- a. Which specialty had the most total number of claims (totaled over all drugs)?


select  specialty_description
          ,sum(total_claim_count) as total_claims
	  from prescriber join prescription using(npi)
	  group by   specialty_description
	 	 	order by total_claims desc
	  ;
	  
select * from prescription;	  
select * from drug;	  
 
 
 
 -- b. Which specialty had the most total number of claims for opioids?
	  
 select specialty_description 
, sum (total_claim_count) as total_claims
 from prescriber join prescription using(npi)
      			join drug using(drug_name)
				group by specialty_description,opioid_drug_flag ='Y'
				-- where  opioid_drug_flag = 'Y'
				ORDER BY total_claims desc;
				 
				 
	--3 a.	 Which drug (generic_name) had the highest total drug cost? 

select generic_name,sum(total_drug_cost) as total_cost
from drug
join prescription using(drug_name)
 group by generic_name
 order by total_cost desc;
 
-- b. Which drug (generic_name) has the hightest total cost per day?
 --**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

  select generic_name,round(sum(total_drug_cost )/sum(total_day_supply) ,2)::money as total_cost_permonth
 from prescription
 join drug using(drug_name)
 group by generic_name
 order by total_cost_permonth desc;
 
 
 
 
--4.
 --   a. For each drug in the drug table, return the drug name and then a column named 'drug_type'
 --which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic'
 --for those drugs which have antibiotic_drug_flag = 'Y',
 --and says 'neither' for all other drugs.
  
select drug_name,
		case
		when  opioid_drug_flag ='Y'then 'OPIOID'
		when antibiotic_drug_flag='Y' then 'ANTIBIOTIC'	
		else 'NEITHER'end as drug_type
from drug;
 
 

  --  b. Building off of the query you wrote for part a,
  --determine whether more was spent (total_drug_cost) on opioids or on antibiotics.
  --Hint: Format the total costs as MONEY for easier comparision.

 
 select 
 drug_name,total_drug_cost ,
		case
		when  opioid_drug_flag ='Y'then 'OPIOID'
		when antibiotic_drug_flag='Y' then 'ANTIBIOTIC'	
		else 'NEITHER'end as drug_type
		
from drug join prescription using (drug_name);



 select 
 --drug_name,
 sum(total_drug_cost::money)as total_cost ,
		case
		when  opioid_drug_flag ='Y'then 'OPIOID'
		when antibiotic_drug_flag='Y' then 'ANTIBIOTIC'	
		else 'NEITHER'
		end as drug_type
		
from drug join prescription using (drug_name)
group by drug_type;



select * from cbsa;

select * from fips_county;

--5
--a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.


select state,count (distinct cbsa) as count_cbsa
from cbsa
join fips_county using(fipscounty)
where state='TN'
group by state
;

--    b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
select 
cbsa,cbsaname,
  sum (population)as total_population 
  from population
inner join cbsa using(fipscounty)
group by cbsa,cbsaname
order by total_population desc;



select 
cbsa,cbsaname,
  sum (population)as total_population 
  from population
inner join cbsa using(fipscounty)
group by cbsa,cbsaname
order by total_population;



select  county,population,fipscounty
from
population
join fips_county using(fipscounty)
order by population desc;





--5c.  What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.


 select county,population
      from population
      join fips_county using (fipscounty)
except
select county,population
      from population
     join fips_county using(fipscounty)
      join cbsa using(fipscounty)
   order by population desc;
 
--6. 
   --a. Find all rows in the prescription table where total_claims is at least 3000. 
   --Report the drug_name and the total_claim_count.



select drug_name,total_claim_count 
from prescription
where total_claim_count>=3000 


--   b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.


select drug_name,total_claim_count,opioid_drug_flag
from prescription join drug using(drug_name)
where total_claim_count>=3000 


-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.




select drug_name
		,total_claim_count
		,opioid_drug_flag
		,nppes_provider_last_org_name
		,nppes_provider_first_name
from prescription join drug using(drug_name)
				join prescriber using(npi)
where total_claim_count>=3000 


--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville
--and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

  --  a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. 
	--You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


select npi,drug_name 
from prescriber 
	cross join drug 
		where specialty_description ilike 'Pain Management' and
		nppes_provider_city ilike 'NASHVILLE' and
		drug.opioid_drug_flag='Y'
		;
	
-- b. Next, report the number of claims per drug per prescriber. 
--Be sure to include all combinations, whether or not the prescriber had any claims. 
--You should report the npi, the drug name, and the number of claims (total_claim_count).
  
	

select npi,drug_name,total_claim_count
from prescriber 
	cross join drug 
	left join prescription using(npi,drug_name)
		where specialty_description ilike 'Pain Management' and
		nppes_provider_city ilike 'NASHVILLE' and
		drug.opioid_drug_flag='Y'
		;
	

--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
--Hint - Google the COALESCE function.

select npi,drug_name,
  COALESCE(total_claim_count,0)
from prescriber 
	cross join drug 
	left join prescription using(npi,drug_name)
		where specialty_description ilike 'Pain Management' and
		nppes_provider_city ilike 'NASHVILLE' and
		drug.opioid_drug_flag='Y'
		;	
		
		
