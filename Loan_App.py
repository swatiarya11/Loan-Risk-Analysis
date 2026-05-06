import streamlit as st
import joblib
import pandas as pd
import numpy as np

# ---------------- LOAD MODEL ----------------
model = joblib.load('Loan_Default_Model.pkl')
model_columns = joblib.load('Model_columns.pkl')

st.set_page_config(page_title="Loan Risk App", layout="wide")

st.title("💳 AI-Powered Loan Risk Decision System")


# ---------------- LOGIN FUNCTION ----------------
def login():
    st.title("🔐 Login Page")

    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        if username == "admin" and password == "1234":
            st.session_state['login'] = True
        else:
            st.error("Invalid credentials")


# ---------------- SESSION CONTROL ----------------
if 'login' not in st.session_state:
    st.session_state['login'] = False


# ---------------- MAIN APP ----------------
if not st.session_state['login']:
    login()

else:
    # Sidebar Navigation
    st.sidebar.title("📌 Navigation")
    page = st.sidebar.radio("Go to", ["📊 EDA", "⚠️ Risk Prediction"])


    # ---------------- EDA TAB ----------------
    if page == "📊 EDA":
        st.title("📊 Exploratory Data Analysis")

        st.subheader("📊 Default Distribution")

        default_counts = pd.Series([9552, 716], index=["No Default", "Default"])
        st.bar_chart(default_counts)
        st.info("Most customers do not default, but a small high-risk segment exists which needs attention.")

        st.markdown("---")
        # ---------- CREDIT SCORE ----------       
        st.subheader("💳 Credit Score vs Default Risk")

        credit_data = pd.DataFrame({
            "Credit Score Range": ["300-500", "500-650", "650-750", "750-900"],
            "Default Rate": [0.65, 0.40, 0.15, 0.05]})

        st.line_chart(credit_data.set_index("Credit Score Range"))

        st.info("Lower credit scores are strongly associated with higher default risk.")

        st.markdown("---")

        # ---------- INCOME ----------
        st.subheader("💰 Income vs Default Risk")

        income_data = pd.DataFrame({
            "Income Level": ["Low", "Medium", "High"],
            "Default Rate": [0.55, 0.25, 0.08]})

        st.bar_chart(income_data.set_index("Income Level"))
        st.info("Customers with higher income levels tend to have significantly lower default probability.")

        st.markdown("---")

        # ---------- DELINQUENCIES ----------
        st.subheader("⚠️ Delinquencies Impact")

        delinq_data = pd.DataFrame({
            "Delinquencies": ["0", "1-2", "3+"],
            "Default Rate": [0.10, 0.35, 0.70]})

        st.bar_chart(delinq_data.set_index("Delinquencies"))
        st.info("Past delinquencies are the strongest indicator of future default behavior.")

        st.markdown("---")

        # ---------- FINAL INSIGHTS ----------
        st.subheader("💡 Key Takeaways")

        st.success("✔ Credit score and delinquency history are the most critical risk factors.")
        st.success("✔ High income customers are relatively safer borrowers.")
        st.success("✔ A small segment contributes disproportionately to default risk.")


    # ---------------- RISK PREDICTION TAB ----------------
    elif page == "⚠️ Risk Prediction":
        st.markdown("## ⚠️ Loan Default Prediction System")

        # Sidebar Inputs
        st.sidebar.header("Enter Customer Details")

        income = st.sidebar.number_input("Monthly Income", value=25000)
        age = st.sidebar.number_input("Age", value=30)
        credit_score = st.sidebar.number_input("Credit Score", value=700)
        delinq = st.sidebar.number_input("Delinquencies", value=0)
        dpd30 = st.sidebar.number_input("30+ DPD", value=0)
        dpd60 = st.sidebar.number_input("60+ DPD", value=0)

        # Predict Button
        if st.sidebar.button("🔍 Predict"):

            # Input Data
            input_dict = {
                'NETMONTHLYINCOME': income,
                'AGE': age,
                'Credit_Score': credit_score,
                'num_times_delinquent': delinq,
                'num_times_30p_dpd': dpd30,
                'num_times_60p_dpd': dpd60
            }

            input_df = pd.DataFrame([input_dict])

            # Align with model columns
            for col in model_columns:
                if col not in input_df.columns:
                    input_df[col] = 0

            input_df = input_df[model_columns]

            # Prediction
            prob = model.predict_proba(input_df)[0][1]

            # ---------------- OUTPUT ----------------
            st.subheader("📊 Prediction Result")
            st.markdown("---")

            st.write(f"Probability of Default: {prob:.4f}")

            if prob < 0.25:
                st.success(f"✅ Low Risk ({prob:.2%})")
            elif prob < 0.6:
                st.warning(f"⚠️ Medium Risk ({prob:.2%})")
            else:
                st.error(f"🚨 High Risk ({prob:.2%})")

            # Progress Bar
            st.progress(float(prob))

            # ---------------- INSIGHTS ----------------
 
            st.subheader("💡 Key Insights")

            insights = []

            if delinq > 0:
                insights.append("Past delinquencies increase risk")

            if dpd30 > 0:
                insights.append("30+ DPD indicates repayment issues")

            if dpd60 > 0:
                insights.append("60+ DPD is a strong risk signal")

            if credit_score < 650:
                insights.append("Low credit score increases risk")

            if income < 20000:
                insights.append("Lower income may affect repayment capacity")

            # Show results
            if len(insights) == 0:
                st.success("Customer shows low default risk based on current inputs")
            else:
                for i in insights:
                    st.write(f"• {i}")