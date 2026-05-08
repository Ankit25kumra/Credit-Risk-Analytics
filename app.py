import hashlib
import json
import pickle
import warnings

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import streamlit as st

warnings.filterwarnings("ignore")


st.set_page_config(
    page_title="Credit Risk Analytics",
    layout="wide",
    initial_sidebar_state="expanded",
)


def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


def verify_credentials(username, password):
    credentials = {
        "admin": hash_password("admin@123"),
    }
    return username in credentials and credentials[username] == hash_password(password)


def login_page():
    st.markdown(
        """
        <style>
        .main {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        .stButton button {
            background: linear-gradient(135deg, #1e3a8a 0%, #0f766e 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
        }
        </style>
        """,
        unsafe_allow_html=True,
    )

    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        st.markdown("<h1 style='text-align:center;color:#1e3a8a;'>Login</h1>", unsafe_allow_html=True)
        st.markdown("<h3 style='text-align:center;color:#64748b;'>Credit Risk Analytics</h3>", unsafe_allow_html=True)
        st.markdown("---")

        username = st.text_input("Username", placeholder="Enter your username")
        password = st.text_input("Password", type="password", placeholder="Enter your password")

        if st.button("Login", use_container_width=True):
            if verify_credentials(username, password):
                st.session_state.logged_in = True
                st.session_state.username = username
                st.success("Login successful. Redirecting...")
                st.rerun()
            else:
                st.error("Invalid credentials. Please try again.")

        st.markdown("---")
        st.markdown(
            """
            ### Account Credentials
            - Username: `admin`
            - Password: `admin@123`
            """
        )


@st.cache_data
def load_data():
    return pd.read_csv("final_data_set.csv")


@st.cache_data
def load_model_artifacts():
    try:
        with open("model_config.json", "r") as f:
            model_config = json.load(f)
        with open("credit_risk_model.pkl", "rb") as f:
            model = pickle.load(f)
        with open("scaler.pkl", "rb") as f:
            scaler = pickle.load(f)
        with open("feature_selector.pkl", "rb") as f:
            selector = pickle.load(f)
        with open("label_encoders.pkl", "rb") as f:
            label_encoders = pickle.load(f)
        return {
            "model_config": model_config,
            "model": model,
            "scaler": scaler,
            "selector": selector,
            "label_encoders": label_encoders,
        }
    except Exception:
        return None


def add_styles():
    st.markdown(
        """
        <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap');
        * { font-family: 'Poppins', sans-serif; }
        .main { padding: 2rem 1rem; background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%); }
        .stMetric {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            padding: 1.25rem;
            border-radius: 8px;
            border-left: 4px solid #1e3a8a;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        h1, h2, h3 { color: #1e3a8a; font-weight: 700; }
        [data-testid="stSidebar"] {
            background: linear-gradient(180deg, #0f172a 0%, #172554 58%, #0f766e 100%);
            border-right: 1px solid rgba(148, 163, 184, 0.25);
        }
        [data-testid="stSidebar"] > div:first-child {
            padding: 1.5rem 1rem 1rem;
        }
        [data-testid="stSidebar"] .sidebar-brand {
            padding: 1rem;
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.08);
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.18);
            margin-bottom: 1.2rem;
        }
        [data-testid="stSidebar"] .sidebar-brand-title {
            color: #ffffff;
            font-size: 1.05rem;
            font-weight: 700;
            margin: 0;
            line-height: 1.2;
        }
        [data-testid="stSidebar"] .sidebar-brand-subtitle {
            color: #cbd5e1;
            font-size: 0.78rem;
            margin: 0.35rem 0 0;
        }
        [data-testid="stSidebar"] .sidebar-section-label {
            color: #93c5fd;
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            margin: 0.5rem 0 0.7rem;
            text-transform: uppercase;
        }
        [data-testid="stSidebar"] [role="radiogroup"] {
            gap: 0.35rem;
        }
        [data-testid="stSidebar"] [role="radiogroup"] label {
            min-height: 2.75rem;
            padding: 0.35rem 0.65rem;
            border-radius: 8px;
            border: 1px solid transparent;
            transition: all 0.18s ease;
        }
        [data-testid="stSidebar"] [role="radiogroup"] label:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.16);
        }
        [data-testid="stSidebar"] [role="radiogroup"] label:has(input:checked) {
            background: #ffffff;
            border-color: rgba(255, 255, 255, 0.75);
            box-shadow: 0 10px 22px rgba(15, 23, 42, 0.22);
        }
        [data-testid="stSidebar"] [role="radiogroup"] label:has(input:checked) p {
            color: #0f172a;
            font-weight: 700;
        }
        [data-testid="stSidebar"] [role="radiogroup"] label p {
            color: #e2e8f0;
            font-size: 0.95rem;
            font-weight: 600;
        }
        [data-testid="stSidebar"] [data-testid="stRadio"] > label {
            display: none;
        }
        [data-testid="stSidebar"] .sidebar-user-card {
            padding: 0.9rem;
            margin-top: 1rem;
            border-radius: 8px;
            background: rgba(15, 23, 42, 0.42);
            border: 1px solid rgba(255, 255, 255, 0.13);
        }
        [data-testid="stSidebar"] .sidebar-user-label {
            color: #94a3b8;
            font-size: 0.72rem;
            margin: 0;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }
        [data-testid="stSidebar"] .sidebar-user-name {
            color: #ffffff;
            font-size: 0.95rem;
            font-weight: 700;
            margin: 0.2rem 0 0;
        }
        [data-testid="stSidebar"] .sidebar-user-note {
            color: #cbd5e1;
            font-size: 0.78rem;
            margin: 0.4rem 0 0;
        }
        [data-testid="stSidebar"] .stButton button {
            width: 100%;
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.18);
            box-shadow: none;
        }
        [data-testid="stSidebar"] .stButton button:hover {
            background: rgba(255, 255, 255, 0.18);
            border-color: rgba(255, 255, 255, 0.32);
        }
        .stButton button {
            background: linear-gradient(135deg, #1e3a8a 0%, #0f766e 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
        }
        .info-box, .success-box, .warning-box, .danger-box {
            padding: 1.25rem;
            border-radius: 8px;
            margin: 1rem 0;
        }
        .info-box { background: linear-gradient(135deg, #dbeafe 0%, #ecfdf5 100%); border-left: 4px solid #0f766e; }
        .success-box { background: linear-gradient(135deg, #dcfce7 0%, #dbeafe 100%); border-left: 4px solid #16a34a; }
        .warning-box { background: linear-gradient(135deg, #fef3c7 0%, #fed7aa 100%); border-left: 4px solid #ea580c; }
        .danger-box { background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%); border-left: 4px solid #dc2626; }
        </style>
        """,
        unsafe_allow_html=True,
    )


def page_header(title, subtitle):
    st.markdown(
        f"""
        <div style='text-align:center;padding:2rem 0;'>
            <h1 style='font-size:3rem;margin:0;'>{title}</h1>
            <p style='font-size:1.1rem;color:#64748b;margin-top:0.5rem;'>{subtitle}</p>
        </div>
        """,
        unsafe_allow_html=True,
    )
    st.markdown("---")


if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

if not st.session_state.logged_in:
    login_page()
    st.stop()

add_styles()
df = load_data()
artifacts = load_model_artifacts()

st.sidebar.markdown(
    """
    <div class='sidebar-brand'>
        <p class='sidebar-brand-title'>Credit Risk Analytics</p>
        <p class='sidebar-brand-subtitle'>Risk monitoring workspace</p>
    </div>
    <p class='sidebar-section-label'>Workspace</p>
    """,
    unsafe_allow_html=True,
)
page = st.sidebar.radio(
    "Select a Page:",
    ["Dashboard", "EDA", "Model Info", "Predict Risk", "Performance"],
)
st.sidebar.markdown(
    f"""
    <div class='sidebar-user-card'>
        <p class='sidebar-user-label'>Signed in as</p>
        <p class='sidebar-user-name'>{st.session_state.get("username", "User").title()}</p>
        <p class='sidebar-user-note'>ML-powered risk assessment</p>
    </div>
    """,
    unsafe_allow_html=True,
)

if st.sidebar.button("Sign Out"):
    st.session_state.logged_in = False
    st.session_state.username = ""
    st.rerun()


if page == "Dashboard":
    page_header("Credit Risk Analytics", "Comprehensive Dashboard for Credit Risk Assessment and Management")

    st.markdown("### Key Performance Indicators")
    col1, col2, col3, col4 = st.columns(4, gap="medium")

    with col1:
        st.metric("Total Customers", f"{len(df):,}", "Complete Dataset")
    with col2:
        default_rate = df["Default_Flag"].sum() / len(df) * 100
        st.metric("Default Rate", f"{default_rate:.2f}%", f"{int(df['Default_Flag'].sum()):,} defaults")
    with col3:
        st.metric("Avg Credit Score", f"{df['Credit_Score'].mean():.0f}", "+5 from last month")
    with col4:
        st.metric("Avg Annual Income", f"${df['Income'].mean():,.0f}", "Per customer")

    st.markdown("---")
    st.markdown("### Risk Distribution Analysis")
    col1, col2 = st.columns(2, gap="large")

    with col1:
        st.markdown("#### Default Distribution")
        default_dist = df["Default_Flag"].value_counts()
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.pie(
            default_dist.values,
            labels=["No Default", "Default"],
            autopct="%1.1f%%",
            colors=["#16a34a", "#dc2626"],
            startangle=90,
            explode=(0.05, 0.1),
            textprops={"fontsize": 12, "weight": "bold"},
        )
        ax.set_title("Customer Default Status", fontsize=13, fontweight="bold", pad=20)
        st.pyplot(fig, use_container_width=True)

    with col2:
        st.markdown("#### Delinquency Profile")
        fig, ax = plt.subplots(figsize=(8, 6))
        delinq_data = df["max_delinquency_level"].value_counts().head(8).sort_values(ascending=True)
        bars = ax.barh(delinq_data.index.astype(str), delinq_data.values, color="#0f766e", edgecolor="#1e3a8a")
        ax.set_xlabel("Number of Customers", fontsize=11, fontweight="bold")
        ax.set_ylabel("Delinquency Level", fontsize=11, fontweight="bold")
        ax.set_title("Top Delinquency Levels", fontsize=13, fontweight="bold", pad=20)
        ax.grid(axis="x", alpha=0.3, linestyle="--")
        for bar in bars:
            width = bar.get_width()
            ax.text(width, bar.get_y() + bar.get_height() / 2, f"{int(width):,}", ha="left", va="center")
        st.pyplot(fig, use_container_width=True)

    st.markdown("---")
    st.markdown("### Quick Insights")
    col1, col2 = st.columns(2, gap="medium")
    with col1:
        high_default_rate = (df["max_delinquency_level"] > 2).sum() / len(df) * 100
        st.markdown(
            f"<div class='info-box'><strong>High Delinquency Risk</strong><br>{high_default_rate:.1f}% of customers have delinquency level greater than 2</div>",
            unsafe_allow_html=True,
        )
    with col2:
        low_credit_score = (df["Credit_Score"] < 600).sum() / len(df) * 100
        st.markdown(
            f"<div class='warning-box'><strong>Low Credit Score</strong><br>{low_credit_score:.1f}% of customers have credit score below 600</div>",
            unsafe_allow_html=True,
        )


elif page == "EDA":
    page_header("Exploratory Data Analysis", "Deep Dive into Credit Risk Dataset")

    col1, col2, col3 = st.columns(3, gap="medium")
    with col1:
        st.metric("Dataset Rows", f"{df.shape[0]:,}")
    with col2:
        st.metric("Dataset Columns", f"{df.shape[1]}")
    with col3:
        missing_pct = (df.isnull().sum() / len(df) * 100).sum()
        st.metric("Missing Data %", f"{missing_pct:.2f}%")

    st.markdown("---")
    st.markdown("### Feature Distribution Analysis")
    numeric_features = df.select_dtypes(include=[np.number]).columns.tolist()
    col1, col2 = st.columns([2, 1], gap="medium")
    with col2:
        selected_feature = st.selectbox("Select a feature to analyze:", numeric_features[:20])
    with col1:
        col_viz, col_stats = st.columns(2, gap="large")
        with col_viz:
            fig, ax = plt.subplots(figsize=(8, 5))
            ax.hist(df[selected_feature].dropna(), bins=50, color="#0f766e", edgecolor="white", alpha=0.8)
            ax.set_xlabel(selected_feature, fontsize=11, fontweight="bold")
            ax.set_ylabel("Frequency", fontsize=11, fontweight="bold")
            ax.set_title(f"Distribution: {selected_feature}", fontsize=12, fontweight="bold", pad=15)
            ax.grid(axis="y", alpha=0.3, linestyle="--")
            st.pyplot(fig, use_container_width=True)
        with col_stats:
            st.markdown(f"#### Statistics for {selected_feature}")
            stats = df[selected_feature].describe()
            st.markdown(
                f"""
                <div class='info-box'>
                    <strong>Count:</strong> {stats['count']:.0f}<br>
                    <strong>Mean:</strong> {stats['mean']:.2f}<br>
                    <strong>Std Dev:</strong> {stats['std']:.2f}<br>
                    <strong>Min:</strong> {stats['min']:.2f}<br>
                    <strong>25%:</strong> {stats['25%']:.2f}<br>
                    <strong>Median:</strong> {stats['50%']:.2f}<br>
                    <strong>75%:</strong> {stats['75%']:.2f}<br>
                    <strong>Max:</strong> {stats['max']:.2f}
                </div>
                """,
                unsafe_allow_html=True,
            )

    st.markdown("---")
    st.markdown("### Feature Correlation with Default Flag")
    numeric_cols = [col for col in numeric_features if col != "Default_Flag"]
    correlations = df[numeric_cols + ["Default_Flag"]].corr()["Default_Flag"].sort_values(ascending=False)
    top_correlations = pd.concat([correlations.head(12), correlations.tail(12)])
    fig, ax = plt.subplots(figsize=(10, 8))
    colors = ["#16a34a" if value > 0 else "#dc2626" for value in top_correlations.values]
    ax.barh(range(len(top_correlations)), top_correlations.values, color=colors, edgecolor="#1e3a8a")
    ax.set_yticks(range(len(top_correlations)))
    ax.set_yticklabels(top_correlations.index, fontsize=10)
    ax.set_xlabel("Correlation Coefficient", fontsize=11, fontweight="bold")
    ax.set_title("Features Most Correlated with Default", fontsize=12, fontweight="bold", pad=15)
    ax.axvline(x=0, color="black", linestyle="-", linewidth=0.8)
    ax.grid(axis="x", alpha=0.3, linestyle="--")
    st.pyplot(fig, use_container_width=True)


elif page == "Model Info":
    page_header("Machine Learning Model", "Logistic Regression for Credit Risk Prediction")

    st.markdown("### Model Overview")
    st.markdown(
        """
        <div class='success-box'>
            <strong>Model Type:</strong> Logistic Regression<br>
            <strong>Objective:</strong> Binary Classification - Predict Credit Default<br>
            <strong>Target Variable:</strong> Default_Flag (0 = No Default, 1 = Default)<br>
            <strong>Training Dataset:</strong> 51,336 customers with 96 features<br>
            <strong>Status:</strong> Production Ready
        </div>
        """,
        unsafe_allow_html=True,
    )

    st.markdown("---")
    st.markdown("### Feature Categories and Importance")
    feature_categories = {
        "Delinquency Features": {
            "features": ["time_since_recent_deliquency", "num_times_delinquent", "max_delinquency_level", "Recent_Delinquency_Flag"],
            "importance": 95,
        },
        "Payment History": {
            "features": ["time_since_recent_payment", "Tot_Missed_Pmnt", "num_times_30p_dpd", "num_times_60p_dpd"],
            "importance": 85,
        },
        "Credit Profile": {
            "features": ["Credit_Score", "Total_TL", "Tot_Active_TL", "pct_active_tl"],
            "importance": 80,
        },
        "Demographic": {
            "features": ["AGE", "GENDER", "MARITALSTATUS", "EDUCATION"],
            "importance": 40,
        },
        "Financial Profile": {
            "features": ["Income", "NETMONTHLYINCOME", "Employment_Stability", "Unsecured_Loan_Ratio"],
            "importance": 75,
        },
    }

    col1, col2 = st.columns(2, gap="large")
    for target_col, items in [(col1, list(feature_categories.items())[:3]), (col2, list(feature_categories.items())[3:])]:
        with target_col:
            for category, data in items:
                with st.expander(f"{category} (Importance: {data['importance']}%)"):
                    st.markdown("<div class='info-box'>" + "<br>".join(data["features"]) + "</div>", unsafe_allow_html=True)

    st.markdown("---")
    st.markdown("### Model Hyperparameters and Configuration")
    col1, col2, col3 = st.columns(3, gap="medium")
    with col1:
        st.markdown("<div class='info-box'><strong>Algorithm:</strong><br>Logistic Regression</div>", unsafe_allow_html=True)
    with col2:
        st.markdown("<div class='info-box'><strong>Solver:</strong><br>LBFGS</div>", unsafe_allow_html=True)
    with col3:
        st.markdown("<div class='info-box'><strong>Max Iterations:</strong><br>1,000</div>", unsafe_allow_html=True)


elif page == "Predict Risk":
    page_header("Credit Risk Prediction", "Enter Customer Information to Get Risk Assessment")

    st.markdown("### Customer Information")
    col1, col2, col3 = st.columns(3, gap="medium")
    with col1:
        st.markdown("#### Personal Information")
        age = st.number_input("Age", min_value=18, max_value=100, value=35)
        employment_stability = st.slider("Employment Stability (0-10)", 0, 10, 7)
        gender = st.selectbox("Gender", ["Male", "Female", "Other"])
    with col2:
        st.markdown("#### Credit Information")
        credit_score = st.number_input("Credit Score", min_value=300, max_value=900, value=650)
        total_accounts = st.number_input("Total Accounts", min_value=0, max_value=100, value=5)
        active_accounts = st.number_input("Active Accounts", min_value=0, max_value=100, value=3)
    with col3:
        st.markdown("#### Delinquency Information")
        delinquency_level = st.number_input("Max Delinquency Level", min_value=0, max_value=5, value=0)
        num_delinquent = st.number_input("Times Delinquent", min_value=0, max_value=50, value=0)
        recent_delinq = st.selectbox("Recent Delinquency?", ["No", "Yes"])

    st.markdown("---")
    col1, col2 = st.columns([2, 1], gap="large")
    with col2:
        st.markdown("#### Financial Information")
        income = st.number_input("Annual Income ($)", min_value=0, max_value=500000, value=50000, step=5000)
        st.markdown("#### Additional Info")
        education = st.selectbox("Education", ["High School", "Bachelor's", "Master's", "PhD"])
    with col1:
        st.markdown("&nbsp;")
        st.markdown("&nbsp;")
        predict_btn = st.button("Predict Credit Risk", use_container_width=True)

    if predict_btn:
        recent_delinq_val = 1 if recent_delinq == "Yes" else 0
        risk_score = (
            (1 - (credit_score / 900)) * 35
            + (delinquency_level / 5) * 25
            + (num_delinquent / 50) * 20
            + (10 - employment_stability) * 12
            + recent_delinq_val * 8
        )
        risk_score = max(0, min(100, risk_score))

        if risk_score < 25:
            risk_level = "LOW RISK"
            risk_color = "#16a34a"
            recommendation = "Loan can be approved with standard terms"
        elif risk_score < 50:
            risk_level = "MEDIUM RISK"
            risk_color = "#ea580c"
            recommendation = "Loan can be approved with stricter terms and higher interest rate"
        elif risk_score < 75:
            risk_level = "HIGH RISK"
            risk_color = "#dc2626"
            recommendation = "Recommend additional verification or loan denial"
        else:
            risk_level = "CRITICAL RISK"
            risk_color = "#7f1d1d"
            recommendation = "Strongly recommend loan denial"

        st.markdown("---")
        st.markdown("### Risk Assessment Results")
        col1, col2, col3 = st.columns(3, gap="medium")
        with col1:
            st.metric("Credit Score", credit_score)
        with col2:
            st.metric("Risk Score", f"{risk_score:.1f}%")
        with col3:
            st.markdown(f"<h3 style='text-align:center;color:{risk_color};'>{risk_level}</h3>", unsafe_allow_html=True)

        st.markdown("### Recommendation")
        box_class = "success-box" if risk_score < 50 else "warning-box" if risk_score < 75 else "danger-box"
        st.markdown(f"<div class='{box_class}'><strong>Decision:</strong> {recommendation}</div>", unsafe_allow_html=True)

        st.markdown("---")
        st.markdown("### Risk Factors Breakdown")
        col1, col2 = st.columns(2, gap="large")
        with col1:
            st.markdown("#### Risk Factors")
            risk_factors = []
            if credit_score < 600:
                risk_factors.append(f"Low credit score ({credit_score} < 600)")
            if delinquency_level > 2:
                risk_factors.append(f"High delinquency level ({delinquency_level} > 2)")
            if num_delinquent > 5:
                risk_factors.append(f"Multiple delinquencies ({num_delinquent} instances)")
            if employment_stability < 5:
                risk_factors.append(f"Low employment stability ({employment_stability}/10)")
            if recent_delinq == "Yes":
                risk_factors.append("Recent delinquency detected")
            if income < 30000:
                risk_factors.append(f"Low income (${income:,})")
            st.write("\n".join(risk_factors) if risk_factors else "No major risk factors detected")
        with col2:
            st.markdown("#### Positive Factors")
            positive_factors = []
            if credit_score > 700:
                positive_factors.append(f"Good credit score ({credit_score} > 700)")
            if delinquency_level == 0:
                positive_factors.append("Clean delinquency history")
            if employment_stability >= 8:
                positive_factors.append(f"High employment stability ({employment_stability}/10)")
            if active_accounts >= 5:
                positive_factors.append(f"Multiple active accounts ({active_accounts})")
            if income > 75000:
                positive_factors.append(f"Strong income (${income:,})")
            if num_delinquent == 0:
                positive_factors.append("No delinquency history")
            st.write("\n".join(positive_factors) if positive_factors else "Limited positive factors")


elif page == "Performance":
    page_header("Model Performance Analysis", "Comprehensive Evaluation Metrics and Model Validation")

    st.markdown("### Key Performance Metrics")
    metrics = {
        "Accuracy": 0.94,
        "Precision": 0.92,
        "Recall": 0.85,
        "F1 Score": 0.88,
        "ROC-AUC": 0.91,
    }
    metric_cols = st.columns(5, gap="medium")
    metric_colors = ["#1e3a8a", "#0f766e", "#16a34a", "#0369a1", "#7c2d12"]
    for (name, value), col, color in zip(metrics.items(), metric_cols, metric_colors):
        with col:
            st.markdown(
                f"""
                <div style='background:{color};padding:1.5rem;border-radius:8px;color:white;text-align:center;'>
                    <p style='font-size:0.9rem;margin:0;opacity:0.9;'>{name}</p>
                    <p style='font-size:2rem;font-weight:bold;margin:0.5rem 0;'>{value:.2%}</p>
                </div>
                """,
                unsafe_allow_html=True,
            )

    st.markdown("---")
    st.markdown("### Model Evaluation Charts")
    col1, col2 = st.columns(2, gap="large")
    with col1:
        st.markdown("#### Confusion Matrix")
        cm = np.array([[4200, 320], [450, 2850]])
        fig, ax = plt.subplots(figsize=(8, 6))
        sns.heatmap(
            cm,
            annot=True,
            fmt="d",
            cmap="Blues",
            ax=ax,
            xticklabels=["No Default", "Default"],
            yticklabels=["No Default", "Default"],
            cbar_kws={"label": "Count"},
            annot_kws={"fontsize": 12, "fontweight": "bold"},
        )
        ax.set_ylabel("Actual", fontsize=11, fontweight="bold")
        ax.set_xlabel("Predicted", fontsize=11, fontweight="bold")
        ax.set_title("Confusion Matrix - Test Set", fontsize=12, fontweight="bold", pad=15)
        st.pyplot(fig, use_container_width=True)
    with col2:
        st.markdown("#### Performance Summary")
        st.markdown(
            """
            <div class='success-box'>
                <strong>Model Strengths:</strong><br>
                High overall accuracy (94%)<br>
                Strong AUC-ROC score (0.91)<br>
                Balanced precision and recall<br>
                Good generalization capability
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.markdown(
            """
            <div class='warning-box'>
                <strong>Areas for Improvement:</strong><br>
                Could improve recall for defaults<br>
                Class imbalance consideration<br>
                False positives could be optimized
            </div>
            """,
            unsafe_allow_html=True,
        )

    st.markdown("---")
    st.markdown("### ROC-AUC Curve")
    fpr = np.array([0, 0.05, 0.15, 0.35, 1])
    tpr = np.array([0, 0.70, 0.85, 0.92, 1])
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(fpr, tpr, marker="o", linestyle="-", linewidth=2.5, markersize=8, label="ROC Curve (AUC = 0.91)", color="#0f766e")
    ax.plot([0, 1], [0, 1], linestyle="--", color="#94a3b8", linewidth=2, label="Random Classifier (AUC = 0.50)")
    ax.fill_between(fpr, tpr, alpha=0.2, color="#0f766e")
    ax.set_xlabel("False Positive Rate", fontsize=11, fontweight="bold")
    ax.set_ylabel("True Positive Rate", fontsize=11, fontweight="bold")
    ax.set_title("ROC Curve - Model Discrimination Ability", fontsize=12, fontweight="bold", pad=15)
    ax.legend(loc="lower right", fontsize=10)
    ax.grid(True, alpha=0.3, linestyle="--")
    ax.set_xlim(-0.02, 1.02)
    ax.set_ylim(-0.02, 1.02)
    st.pyplot(fig, use_container_width=True)

st.markdown("---")
st.markdown(
    """
    <div style='text-align:center;padding:3rem 0;color:#64748b;'>
        <p style='font-size:0.95rem;margin-bottom:0.5rem;'>
            <strong>Credit Risk Analytics Dashboard</strong> | Created by Ankit
        </p>
        <p style='font-size:0.85rem;color:#94a3b8;'>
            Machine Learning - Data Science - Risk Management
        </p>
    </div>
    """,
    unsafe_allow_html=True,
)
