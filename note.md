# Project Methodology & Technical Notes (`note.md`)

## 1. Arxitektura
* **Data Hazırlığı və Transformasiya:** Məlumatların təmizlənməsi, tip çevrilmələri (type-casting) və ilkin xüsusiyyət mühəndisliyi (feature engineering) üçün **SQLite (DB Browser)** istifadə olunmuşdur.
* **Modelləşdirmə və Vizualizasiya:** **Power BI Desktop** (explicit DAX ölçüləri və Power Query transformasiyaları).

## 2. Yaradılmış Xüsusi Sütunlar və DAX Ölçüləri (Engineered Features & Measures)
* **`attrition_flag`**: Xam `Attrition` sütunundan əldə edilən ikili (binary) xəritələmə (`1` - işdən ayrılanlar "Yes", `0` - qalanlar "No") — düzgün aqreqasiya üçün istifadə olunub.
* **`TenureBand`**: İşçinin şirkətdəki stajına (`YearsAtCompany`) əsasən qruplaşdırılmış seqmentasiya (`0-2 years`, `3-5 years`, `6-10 years`, `11+ years`).
* **`IncomeQuartile`**: Aylıq gəlirləri faiz hədləri əsasında dörd bərabər paya (kvartilə) bölən seqment (`Q1`, `Q2`, `Q3`, `Q4`).
* **Əsas DAX Ölçüləri (Core Measures):**
  * `Headcount = COUNTROWS(employees)`
  * `Attritions = CALCULATE(COUNTROWS(employees), employees[attrition_flag] = 1)`
  * `Attrition Rate % = DIVIDE([Attritions], [Headcount], 0)`

## 3. SQL və Power BI Çarpaz Yoxlama Nəticələri (Cross-Validation)
Məlumatların bütövlüyünü və dəqiqliyini təmin etmək üçün əsas seqmentlər üzrə göstəricilər SQLite sorğuları və Power BI DAX çıxışları arasında müqayisə edilmiş və tam uyğunluq əldə olunmuşdur:
* **Sales Departamenti Üzrə Attrition Rate:** SQL (20.63%) ⟷ Power BI (20.63%) ✅
* **OverTime = Yes Qrupu Üzrə Attrition Rate:** SQL (30.53%) ⟷ Power BI (30.53%) ✅
* **0–2 İl Staj Qrupu (TenureBand) Üzrə Attrition Rate:** SQL (29.82%) ⟷ Power BI (29.82%) ✅
