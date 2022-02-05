select *
from prescriber
where nppes_provider_last_org_name = 'LEBOW'

SELECT *
FROM drug

SELECT *
FROM prescription

SELECT *
FROM cbsa

SELECT *
FROM fips_county

SELECT *
FROM population

--QUESTION 1A: answer: 1881634483 and 99707 work below

select npi, nppes_provider_last_org_name,SUM(total_claim_count) as all_drugs
FROM 
	(SELECT prescription.npi, nppes_provider_first_name, specialty_description, nppes_provider_last_org_name, total_claim_count
	 FROM prescription 
	 FULL JOIN prescriber
	 USING (npi)
	WHERE total_claim_count is not null)
	 AS doc_script_npi	 
group by npi, nppes_provider_last_org_name
order by all_drugs desc

--QUESTION 1A: answer: 1881634483 Bruce Pendley Family Practice 99707, work below
select npi, (nppes_provider_first_name||nppes_provider_last_org_name || specialty_description) as name_and_specialty, SUM(total_claim_count) as all_drugs
FROM 
	(SELECT prescription.npi, nppes_provider_first_name, specialty_description, nppes_provider_last_org_name, total_claim_count
	 FROM prescription 
	 FULL JOIN prescriber
	 USING (npi)
	WHERE total_claim_count is not null)
	 AS doc_script_npi	 
group by npi, name_and_specialty
order by all_drugs desc
LIMIT 1

--question 2 a: family practice
select specialty_description,SUM(total_claim_count) as all_drugs
FROM 
	(SELECT prescription.npi, nppes_provider_first_name, specialty_description, nppes_provider_last_org_name, total_claim_count
	 FROM prescription 
	 FULL JOIN prescriber
	 USING (npi)
	WHERE total_claim_count is not null)
	 AS doc_script_npi	 
group by specialty_description
order by all_drugs desc


---question 2 b: Nurse Practitioner

select specialty_description, opioid_drug_flag, SUM(total_claim_count) as all_drugs
FROM 
	(SELECT p1.npi, nppes_provider_first_name, specialty_description, nppes_provider_last_org_name, total_claim_count, drug.drug_name, opioid_drug_flag
	 FROM prescription as p1
	 FULL JOIN prescriber as p2
	 on p1.npi= p2.npi
	 full join drug
	 on p1.drug_name = drug.drug_name
	WHERE total_claim_count is not null
	and opioid_drug_flag= 'Y')
	 AS doc_script_npi_drug 
group by specialty_description, opioid_drug_flag
order by all_drugs desc


--question 2 c: i believe so, these are the ones that have nulls in the all_drugs catagory

select specialty_description, opioid_drug_flag, SUM(total_claim_count) as all_drugs
FROM 
	(SELECT p1.npi, nppes_provider_first_name, specialty_description, nppes_provider_last_org_name, total_claim_count, drug.drug_name, opioid_drug_flag
	 FROM prescription as p1
	 FULL JOIN prescriber as p2
	 on p1.npi= p2.npi
	 full join drug
	 on p1.drug_name = drug.drug_name)
	 AS doc_script_npi_drug 
group by specialty_description, opioid_drug_flag
having sum(total_claim_count) is null


----------------
SELECT generic_name, total_drug_cost:: MONEY
FROM prescription
LEFT JOIN drug
USING (drug_name)
order by total_drug_cost:: MONEY DESC
limit 1
---or
SELECT generic_name, SUM(total_drug_cost:: MONEY)
FROM prescription
LEFT JOIN drug
USING (drug_name)
GROUP BY generic_name
order by SUM(total_drug_cost:: MONEY) DESC
limit 1
---3a above, pirfenidone or insulin

SELECT generic_name, total_drug_cost/total_day_supply as cost_per_day
FROM prescription
LEFT JOIN drug
USING (drug_name)
order by cost_per_day DESC
limit 1
--- 3b Immun glob (IGG)/gly/iga ova 50 7141.11

SELECT drug_name,
	case when opioid_drug_flag= 'Y' then  'opioid'
		 when antibiotic_drug_flag= 'Y' then 'antibiotic' 
		 Else 'neither' end
		 as drug_type
FROM drug
full join prescription
using (drug_name)
order by drug_type
---------
SELECT Sum(total_drug_cost:: MONEY),
	case when opioid_drug_flag= 'Y' then  'opioid'
		 when antibiotic_drug_flag= 'Y' then 'antibiotic' 
		 Else 'neither' end
		 as drug_type
FROM drug
full join prescription
using (drug_name)
group by opioid_drug_flag, antibiotic_drug_flag
order by Sum(total_drug_cost:: MONEY)
----- neither, then opioids, then antibiotics----question 4a and b above

select*
from cbsa
full join fips_county
using(fipscounty)
full join population
using (fipscounty)
where state = 'TN'
-----

select count(distinct cbsa)
from cbsa
full join fips_county
using(fipscounty)
where state = 'TN'
---question 5a: 10

select distinct cbsa, sum(population)
from cbsa
full join fips_county
using(fipscounty)
full join population
using (fipscounty)
where state = 'TN'
group by distinct cbsa
order by sum(population)

---question 5b 34100 has the fewest 34980 at 116352 has the most 183410

select distinct cbsa, sum(population), county
from cbsa
full join fips_county
using(fipscounty)
full join population
using (fipscounty)
where state = 'TN'
AND cbsa is null
group by distinct cbsa, county
order by sum(population) desc
---sevier at 95523

select drug_name, total_claim_count
from prescription
where total_claim_count> 3000
-------------------
SELECT drug_name, total_claim_count, nppes_provider_first_name, nppes_provider_last_org_name,
	case when opioid_drug_flag= 'Y' then  'opioid'
		 Else 'neither' end
		 as drug_type
FROM drug
full join prescription
using (drug_name)
full join prescriber
using (npi)
where total_claim_count> 3000
order by drug_type DESC

------------------------
---Below Question 7



SELECT p2.npi,
	d.drug_name,
	COALESCE(total_claim_count, 0)
FROM prescriber AS p2
CROSS JOIN drug AS d
LEFT JOIN prescription AS p1
  ON p1.npi = p2.npi
  AND d.drug_name = p1.drug_name
where p2.nppes_provider_city = 'NASHVILLE'
AND p2.specialty_description= 'Pain Management'
and opioid_drug_flag= 'Y'
order by  npi

------------------PART 2-------------
SELECT count(npi)
FROM prescriber
FULL JOIN prescription
USING (npi)
---660516
SELECT count(npi)
FROM prescription
LEFT JOIN prescriber
USING (npi)


