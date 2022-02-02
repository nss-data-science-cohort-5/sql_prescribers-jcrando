select *
from prescriber
where nppes_provider_last_org_name = 'LEBOW'

SELECT *
FROM drug

SELECT *
FROM prescription

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
order by all_drugs desc