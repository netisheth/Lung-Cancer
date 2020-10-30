#' Data: LungCancer.txt

#' Read and clean data

d <- read.table("LungCancer.txt", skip=15)
colnames(d) <- c("treatment", "cell_type", "survival",	"status",	"karnofsky_score",
                "months_from_diagnosis", "age", "prev_chemo")
View(d)
str(d)

col <- c("treatment", "cell_type", "prev_chemo")
d[col] <- lapply(d[col], factor)
str(d)

d$treatment <- relevel(d$treatment, ref="1")
levels(d$prev_chemo) = c(0,1)
d$prev_chemo <- relevel(d$prev_chemo, ref="0")

#' Descriptive analysis

summary(d$survival)
table(d$treatment)
table(d$status)
table(d$cell_type)
table(d$prev_chemo)

#' Obs: Almost equal number of standard treatment and test treatment, i.e., sample is balanced.
#' 128 out of 137 patients died during the study and 9 patient records are censored.

#' Survival variable: Event : Patient dies => status == 1 
#'                    Time  : survival

#' Kaplan-Meier non-parametric analysis

# install.packages("survival")
library(survival)
km <- survfit(Surv(survival, status) ~ treatment, data=d)
summary(km)

# install.packages("survminer")
library(survminer)
ggsurvplot(fit=km, xlab="Days", ylab="Survival Probability")

#' Survival probability at 1 year (365 days) on standard vs test treatment 
summary(km, times=365)
#' Answer: 7% of patients on standard treatment (=1, chemo only) are expected to 
#' survive 1 year compared to 11% of patients on test treatment (=0, chemo + new drug).
#' 95% CI for standard group is (3%, 18%) and for test group is (5%, 23%).

#' Survival probability at 6 months (183 days) on standard vs test treatment 
summary(km, times=183)
#' Answer: 21% of patients on standard treatment (=1, chemo only) are expected to 
#' survive 6 months compared to 23% of patients on test treatment (=0, chemo + new drug).

#' Median number of days a patient is expected to survive on standard vs the test treatment
print(km)
#' Answer: 103 days on standard treatment vs 52 days on test treatment

#' Interpretation:
#' 
#' The test treatment outperforms the standard treatment on survival probability at 6 months 
#' and 1 year. However, the KM plot shows that this pattern is not consistent.
#' For the first 24 days,both treatments have comparable survival probablities (around 75%). 
#' After that, the standard treatment outperforms the test treatment on survival probablity 
#' until around 200 days. Beyond 200 days, the test treatment shows better survival probablity.
#' This could mean that it takes about 6 months to start seeing the effects of the new drug.

#' Semi-parametric  and parametric  analysis

#' Predictor variables selected for analysis:
#'  Treatment: We want to examine the effect of the two treatments on survival outcomes
#'  Months from diagnosis: People diagnosed late may not respond effectively to treatment
#'  Age (years): Older patients may respond differently to treatment than younger patients
#'  Prior chemotherapy (0=no, 1=yes): Prior chemo may influence the outcome of the treatment. 
#'  Cell type: There are two main types of lung cancer: small cell (2=small cell) and 
#'             non-small cell (1=squamous, 3=adeno, 4=large). The treatment may respond 
#'             differently to the type of cancer.

#' Variables not considered as predictors:
#'  Karnofsky score: This score measures the ability of cancer patients to perform ordinary tasks.
#'             It may be used to determine a patient's prognosis, to measure changes in a patient's 
#'             ability to function, or to decide if a patient could be included in a clinical trial.
#'             It is unclear how it may related to treatment outcome.

#' Feature engineering
d$cancer_type <- ifelse(d$cell_type=="2", "small_cell", "non-small_cell")
d$cancer_type <- factor(d$cancer_type)
d$cancer_type <- relevel(d$cancer_type, ref="small_cell")

#' Cox proportional hazard model 
cox <- coxph(Surv(survival, status) ~ treatment + cancer_type + age + months_from_diagnosis +
            prev_chemo + treatment*age + treatment*cancer_type, data=d, method="breslow")
summary(cox)

#' Exponential, Weibull, and log-logistic parametric models
exp <- survreg(Surv(survival, status) ~ treatment + cancer_type + age + months_from_diagnosis +
            prev_chemo + treatment*age + treatment*cancer_type, data=d, dist="exponential")

weibull <- survreg(Surv(survival, status) ~ treatment + cancer_type + age + months_from_diagnosis +
            prev_chemo + treatment*age + treatment*cancer_type, data=d, dist="weibull")

loglogistic <- survreg(Surv(survival, status) ~ treatment + cancer_type + age + months_from_diagnosis +
            prev_chemo + treatment*age + treatment*cancer_type, data=d, dist="loglogistic")

library(stargazer)
stargazer(cox, exp, weibull, loglogistic, type="text")

#' Interpretation:
#' 
#' Cox proportional hazard model reports estimated hazard rates, which are pretty consistent with 
#' survival probabilities reported by Exponential and Weibull models, all of which are a little 
#' different from the log-logistic model. Hence, we will use the Cox PH model for interpretation.
#' 
#' The hazard rate of the test treatment is greater than the standard treatment by exp(0.55) = 73%.
#' Age has no significant effect on hazard rate on its own (0.4%) or in interaction with different 
#' treatments (<0.1%). Months from diagnosis also seems to have an insubstantive effect (0.7%).
#' Previous chemotherapy decreases hazard rate by 14% (independent of treatment).
#' Non-small cell cancer has a 43% less hazard rate for the test treatment compared to standard 
#' treatment and a 61% less hazard rate compared to small-cell cancer. None of these coefficients
#' are significant due to high standard error, possibly caused by small sample size.

