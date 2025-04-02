import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from textblob import TextBlob
import numpy as np
from wordcloud import WordCloud
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import nltk
from nltk.corpus import stopwords
import seaborn as sns
from scipy import stats
from collections import Counter
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import PCA

# Try importing networkx
try:
    import networkx as nx
    NETWORKX_AVAILABLE = True
except ImportError:
    NETWORKX_AVAILABLE = False
    st.warning("NetworkX is not installed. Network analysis features will be disabled.")

# Download required NLTK data
try:
    nltk.download('stopwords')
    nltk.download('punkt')
    nltk.download('averaged_perceptron_tagger')
except Exception as e:
    st.warning(f"Error downloading NLTK data: {e}")

# Set page config
st.set_page_config(
    page_title="MacBook Website Ranking Analysis",
    page_icon="🍎",
    layout="wide"
)

# Custom CSS
st.markdown("""
    <style>
    .main {
        background-color: #f8f9fa;
    }
    .stButton>button {
        background-color: #007aff;
        color: white;
        border-radius: 20px;
        padding: 10px 20px;
    }
    .stTextInput>div>div>input {
        border-radius: 10px;
    }
    .metric-card {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin: 10px 0;
    }
    .analysis-section {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        margin: 10px 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    </style>
    """, unsafe_allow_html=True)

# Title and description
st.title("🍎 MacBook Website Ranking Analysis")
st.markdown("Analyze website rankings and reviews for MacBook products")

# Sidebar for input
with st.sidebar:
    st.header("Input Data")
    st.markdown("Enter website URLs and their rankings:")
    
    # Sample data
    sample_data = {
        'Website': ['amazon.com', 'bestbuy.com', 'walmart.com', 'apple.com', 'bhphotovideo.com'],
        'Ranking': [1, 2, 3, 4, 5],
        'Reviews': [
            "Great product! The M2 chip is amazing. Battery life is excellent. Perfect for professional work.",
            "Best MacBook I've ever used. Display is stunning. Performance is incredible.",
            "Good value for money. Performance is top-notch. Battery life could be better.",
            "Perfect for professional work. Build quality is exceptional. M2 chip is powerful.",
            "Excellent customer service. Product meets expectations. Display quality is great."
        ]
    }
    
    # Create input fields
    websites = st.text_area("Enter website URLs (one per line)", 
                          "\n".join(sample_data['Website']))
    rankings = st.text_area("Enter rankings (one per line)", 
                          "\n".join(map(str, sample_data['Ranking'])))
    reviews = st.text_area("Enter reviews (one per line)", 
                         "\n".join(sample_data['Reviews']))

# Process the input data
def process_data(websites, rankings, reviews):
    websites_list = [w.strip() for w in websites.split('\n') if w.strip()]
    rankings_list = [int(r.strip()) for r in rankings.split('\n') if r.strip()]
    reviews_list = [r.strip() for r in reviews.split('\n') if r.strip()]
    
    df = pd.DataFrame({
        'Website': websites_list,
        'Ranking': rankings_list,
        'Review': reviews_list
    })
    return df

# Create tabs for different analyses
tab1, tab2, tab3, tab4 = st.tabs(["Ranking Analysis", "Review Analysis", "Trends", "Advanced Analysis"])

# Process the data
df = process_data(websites, rankings, reviews)

# Tab 1: Ranking Analysis
with tab1:
    st.header("Website Ranking Analysis")
    
    # Create ranking visualization
    col1, col2 = st.columns([2, 1])
    with col1:
        fig_ranking = px.bar(df, x='Website', y='Ranking',
                           title="Website Rankings",
                           color='Ranking',
                           color_continuous_scale='Viridis')
        fig_ranking.update_layout(
            xaxis_title="Website",
            yaxis_title="Ranking (Lower is Better)",
            showlegend=False,
            height=400
        )
        st.plotly_chart(fig_ranking, use_container_width=True)
    
    with col2:
        st.markdown("### Key Metrics")
        st.markdown('<div class="metric-card">', unsafe_allow_html=True)
        st.metric("Average Ranking", f"{df['Ranking'].mean():.1f}")
        st.metric("Best Ranking", df['Ranking'].min())
        st.metric("Worst Ranking", df['Ranking'].max())
        st.markdown('</div>', unsafe_allow_html=True)
        
        # Add ranking distribution
        fig_dist = px.histogram(df, x='Ranking',
                              title="Ranking Distribution",
                              nbins=10)
        fig_dist.update_layout(height=300)
        st.plotly_chart(fig_dist, use_container_width=True)

# Tab 2: Review Analysis
with tab2:
    st.header("Review Analysis")
    
    # Sentiment Analysis
    def get_sentiment(text):
        return TextBlob(text).sentiment.polarity
    
    df['Sentiment'] = df['Review'].apply(get_sentiment)
    
    # Create two columns for sentiment analysis
    col1, col2 = st.columns(2)
    
    with col1:
        # Sentiment distribution
        fig_sentiment = px.histogram(df, x='Sentiment',
                                  title="Sentiment Distribution",
                                  nbins=20)
        fig_sentiment.update_layout(height=400)
        st.plotly_chart(fig_sentiment, use_container_width=True)
        
        # Sentiment by Website
        fig_sentiment_website = px.box(df, x='Website', y='Sentiment',
                                    title="Sentiment Distribution by Website")
        fig_sentiment_website.update_layout(height=400)
        st.plotly_chart(fig_sentiment_website, use_container_width=True)
    
    with col2:
        # Word Cloud
        st.subheader("Word Cloud of Reviews")
        text = ' '.join(df['Review'])
        wordcloud = WordCloud(width=800, height=400, 
                            background_color='white',
                            colormap='viridis').generate(text)
        fig, ax = plt.subplots(figsize=(10, 5))
        ax.imshow(wordcloud, interpolation='bilinear')
        ax.axis('off')
        st.pyplot(fig)
        
        # Sentiment metrics
        st.markdown("### Sentiment Metrics")
        st.markdown('<div class="metric-card">', unsafe_allow_html=True)
        st.metric("Average Sentiment", f"{df['Sentiment'].mean():.2f}")
        st.metric("Most Positive", df.loc[df['Sentiment'].idxmax(), 'Website'])
        st.metric("Most Negative", df.loc[df['Sentiment'].idxmin(), 'Website'])
        st.markdown('</div>', unsafe_allow_html=True)

# Tab 3: Trends
with tab3:
    st.header("Trend Analysis")
    
    # Generate sample trend data
    dates = pd.date_range(start='2024-01-01', periods=30, freq='D')
    trend_data = pd.DataFrame({
        'Date': dates,
        'Amazon': np.random.normal(1, 0.2, 30),
        'BestBuy': np.random.normal(2, 0.2, 30),
        'Walmart': np.random.normal(3, 0.2, 30)
    })
    
    # Create two columns for trend analysis
    col1, col2 = st.columns(2)
    
    with col1:
        # Ranking trends
        fig_trends = px.line(trend_data, x='Date', y=['Amazon', 'BestBuy', 'Walmart'],
                           title="Ranking Trends Over Time")
        fig_trends.update_layout(height=400)
        st.plotly_chart(fig_trends, use_container_width=True)
        
        # Trend metrics
        st.markdown("### Trend Metrics")
        st.markdown('<div class="metric-card">', unsafe_allow_html=True)
        st.metric("Amazon Trend", f"{trend_data['Amazon'].mean():.2f}")
        st.metric("BestBuy Trend", f"{trend_data['BestBuy'].mean():.2f}")
        st.metric("Walmart Trend", f"{trend_data['Walmart'].mean():.2f}")
        st.markdown('</div>', unsafe_allow_html=True)
    
    with col2:
        # Correlation heatmap
        st.subheader("Website Ranking Correlations")
        correlation_matrix = trend_data[['Amazon', 'BestBuy', 'Walmart']].corr()
        fig_corr = px.imshow(correlation_matrix,
                           title="Ranking Correlation Heatmap",
                           color_continuous_scale='RdBu')
        fig_corr.update_layout(height=400)
        st.plotly_chart(fig_corr, use_container_width=True)
        
        # Add trend analysis
        st.subheader("Trend Analysis")
        trend_analysis = pd.DataFrame({
            'Website': ['Amazon', 'BestBuy', 'Walmart'],
            'Trend': ['Stable', 'Improving', 'Declining'],
            'Change': ['+0.1', '+0.3', '-0.2']
        })
        st.dataframe(trend_analysis, use_container_width=True)

# Tab 4: Advanced Analysis
with tab4:
    st.header("Advanced Analysis")
    
    # Create three columns for advanced analysis
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown("### Statistical Analysis")
        st.markdown('<div class="analysis-section">', unsafe_allow_html=True)
        
        # Calculate statistical measures
        stats_data = {
            'Metric': ['Mean', 'Median', 'Mode', 'Standard Deviation', 'Skewness'],
            'Value': [
                f"{df['Ranking'].mean():.2f}",
                f"{df['Ranking'].median():.2f}",
                f"{df['Ranking'].mode()[0]:.2f}",
                f"{df['Ranking'].std():.2f}",
                f"{df['Ranking'].skew():.2f}"
            ]
        }
        stats_df = pd.DataFrame(stats_data)
        st.dataframe(stats_df, use_container_width=True)
        
        # Create a violin plot
        plt.figure(figsize=(8, 4))
        sns.violinplot(data=df, y='Ranking')
        plt.title("Ranking Distribution (Violin Plot)")
        st.pyplot(plt)
        st.markdown('</div>', unsafe_allow_html=True)
    
    with col2:
        st.markdown("### Text Analysis")
        st.markdown('<div class="analysis-section">', unsafe_allow_html=True)
        
        # TF-IDF Analysis
        vectorizer = TfidfVectorizer(max_features=10)
        tfidf_matrix = vectorizer.fit_transform(df['Review'])
        feature_names = vectorizer.get_feature_names_out()
        
        # Create TF-IDF visualization
        plt.figure(figsize=(10, 6))
        tfidf_means = tfidf_matrix.mean(axis=0).A1
        plt.bar(feature_names, tfidf_means)
        plt.xticks(rotation=45)
        plt.title("Top 10 Important Words (TF-IDF)")
        plt.tight_layout()
        st.pyplot(plt)
        
        # Word frequency analysis
        words = ' '.join(df['Review']).lower().split()
        word_freq = Counter(words)
        top_words = dict(word_freq.most_common(5))
        
        plt.figure(figsize=(8, 4))
        plt.bar(top_words.keys(), top_words.values())
        plt.title("Top 5 Most Frequent Words")
        plt.xticks(rotation=45)
        plt.tight_layout()
        st.pyplot(plt)
        st.markdown('</div>', unsafe_allow_html=True)
    
    with col3:
        st.markdown("### Network Analysis")
        st.markdown('<div class="analysis-section">', unsafe_allow_html=True)
        
        if NETWORKX_AVAILABLE:
            try:
                # Create a simple network graph
                G = nx.Graph()
                websites = df['Website'].tolist()
                for i in range(len(websites)):
                    for j in range(i+1, len(websites)):
                        G.add_edge(websites[i], websites[j])
                
                plt.figure(figsize=(8, 6))
                pos = nx.spring_layout(G)
                nx.draw(G, pos, with_labels=True, node_color='lightblue', 
                        node_size=1000, font_size=8, font_weight='bold')
                plt.title("Website Network Graph")
                st.pyplot(plt)
                
                # Add network metrics
                network_metrics = {
                    'Metric': ['Number of Nodes', 'Number of Edges', 'Average Degree'],
                    'Value': [
                        G.number_of_nodes(),
                        G.number_of_edges(),
                        f"{sum(dict(G.degree()).values()) / G.number_of_nodes():.2f}"
                    ]
                }
                network_df = pd.DataFrame(network_metrics)
                st.dataframe(network_df, use_container_width=True)
            except Exception as e:
                st.error(f"Error creating network graph: {e}")
        else:
            st.info("Network analysis features are disabled. Please install networkx to enable this feature.")
        
        st.markdown('</div>', unsafe_allow_html=True)

# Footer
st.markdown("---")
st.markdown("Built with Streamlit • Data updated daily") 