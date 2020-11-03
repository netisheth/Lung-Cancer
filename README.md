# Lung-Cancer

Determined how long a patient is likely to survive advanced inoperable lung cancer when treated with chemotherapy (standard treatment) vs chemotherapy combined with a new drug (test treatment).

Data gathered from Veteran's Administration Lung Cancer Trial, where 137 patients with advanced, inoperable lung cancer were treated with chemotherapy (standard treatment) vs chemotherapy combined with a new drug (test treatment).

### 1. Kaplan-Meier survival graphs for patients with the test vs standard treatment.

<img src="https://github.com/netisheth/Lung-Cancer/blob/main/Pictures/SurvivalProbability.png" alt="alt text" width="50%" height="50%">

Observations:

-  7% of patients on standard treatment (=1, chemo only) are expected to survive 1 year compared to 11% of patients on test treatment (=0, chemo + new drug). 95% CI for standard group is (3%, 18%) and for test group is (5%, 23%).

-  21% of patients on standard treatment (=1, chemo only) are expected to survive 6 months compared to 23% of patients on test treatment (=0, chemo + new drug).

-  The patient is expected to survive for 103 days (median) on standard treatment compared to 52 days on test treatment

The test treatment outperforms the standard treatment on survival probability at 6 months and 1 year. However, the KM plot shows that this pattern is not consistent. For the first 24 days,both treatments have comparable survival probablities (around 75%). After that, the standard treatment outperforms the test treatment on survival probablity until around 200 days. Beyond 200 days, the test treatment shows better survival probablity. This could mean that it takes about 6 months to start seeing the effects of the new drug.

### 2. Semi-parametric and parametric  analysis

Predictor variables selected for analysis:
- Treatment: We want to examine the effect of the two treatments on survival outcomes
- Months from diagnosis: People diagnosed late may not respond effectively to treatment
- Age (years): Older patients may respond differently to treatment than younger patients
- Prior chemotherapy (0=no, 1=yes): Prior chemo may influence the outcome of the treatment. 
- Cell type: There are two main types of lung cancer: small cell (2=small cell) and non-small cell (1=squamous, 3=adeno, 4=large). The treatment may respond differently to the type of cancer.

Variables not considered as predictors:
- Karnofsky score: This score measures the ability of cancer patients to perform ordinary tasks. It may be used to determine a patient's prognosis, to measure changes in a patient's ability to function, or to decide if a patient could be included in a clinical trial. It is unclear how it may related to treatment outcome.

<img src="https://github.com/netisheth/Lung-Cancer/blob/main/Pictures/ModelSummary.png" alt="alt text" width="50%" height="50%">

Cox proportional hazard model reports estimated hazard rates, which are pretty consistent with survival probabilities reported by Exponential and Weibull models, all of which are a little different from the log-logistic model. Hence, we will use the Cox PH model for interpretation.

The hazard rate of the test treatment is greater than the standard treatment by exp(0.55) = 73%. Age has no significant effect on hazard rate on its own (0.4%) or in interaction with different treatments (<0.1%). Months from diagnosis also seems to have an insubstantive effect (0.7%). Previous chemotherapy decreases hazard rate by 14% (independent of treatment). Non-small cell cancer has a 43% less hazard rate for the test treatment compared to standard treatment and a 61% less hazard rate compared to small-cell cancer. None of these coefficients are significant due to high standard error, possibly caused by small sample size.
