#!/usr/bin/env python3
"""
LangChain Playground: Core Concepts & Practical Examples
Covers: LLM interactions, Prompts, Chains, Memory, Agents, Document Q&A, and more
Note: Requires: pip install langchain openai python-dotenv
"""

# ============================================================================
# IMPORTANT SETUP INSTRUCTIONS
# ============================================================================
"""
Before running this playground, you need to:

1. Install required packages:
   pip install langchain openai python-dotenv tiktoken

2. Set up your API keys (create a .env file in the project root):
   OPENAI_API_KEY=your_openai_api_key_here
   
   Or set environment variables:
   export OPENAI_API_KEY="your_openai_api_key_here"  (Linux/Mac)
   $env:OPENAI_API_KEY="your_openai_api_key_here"     (PowerShell)

3. Alternative LLM providers (choose based on your setup):
   - OpenAI (recommended for this playground)
   - Anthropic Claude
   - Cohere
   - HuggingFace
   - Local models via Ollama

This playground contains both:
- Fully working examples (that work without API keys)
- Example code (marked as commented, for when you have API keys)
"""

import os
from dotenv import load_dotenv
from typing import List

# Load environment variables from .env file
load_dotenv()

print("\n" + "="*70)
print("LANGCHAIN PLAYGROUND: CORE CONCEPTS & PRACTICAL EXAMPLES")
print("="*70 + "\n")

# ============================================================================
# SECTION 1: LANGCHAIN FUNDAMENTALS & SETUP
# ============================================================================

print("\n" + "-"*70)
print("SECTION 1: LANGCHAIN FUNDAMENTALS & SETUP")
print("-"*70 + "\n")

print("LangChain is a framework for developing applications with LLMs")
print("\nKey Components:")
print("  1. LLMs/ChatModels - Language models that generate text")
print("  2. Prompts - Instructions/templates for the model")
print("  3. Chains - Sequential operations combining multiple components")
print("  4. Memory - Conversation history and context management")
print("  5. Agents - Autonomous systems using tools to accomplish tasks")
print("  6. Tools - Functions that agents can call (APIs, calculators, etc.)")
print("  7. Document Loaders - Read various document formats")
print("  8. Vectorstores - Store embeddings for semantic search")

print("\nLangChain Architecture:")
print("  User Input → Prompt Template → LLM → Parser → Output")
print("  Memory ↔ Chain ↔ Agent ↔ Tools")

# ============================================================================
# SECTION 2: PROMPT TEMPLATES
# ============================================================================

print("\n" + "-"*70)
print("SECTION 2: PROMPT TEMPLATES")
print("-"*70 + "\n")

# Example 1: Simple prompt template
print("Example 1: Simple Prompt Template")
from langchain.prompts import PromptTemplate

# Create a prompt template
prompt_template = PromptTemplate(
    input_variables=["topic", "audience"],
    template="Write a brief explanation of {topic} for {audience}."
)

# Format the prompt
formatted_prompt = prompt_template.format(topic="Machine Learning", audience="beginners")
print(f"  Template: {prompt_template.template}")
print(f"  Formatted: {formatted_prompt}\n")

# Example 2: Chat prompt template
print("Example 2: Chat Prompt Template")
from langchain.prompts import ChatPromptTemplate, HumanMessagePromptTemplate, SystemMessagePromptTemplate

chat_template = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template("You are a helpful assistant expert in {domain}."),
    HumanMessagePromptTemplate.from_template("Question: {question}")
])

formatted_chat = chat_template.format_messages(domain="Python Programming", question="How do decorators work?")
print(f"  System message: {formatted_chat[0].content}")
print(f"  Human message: {formatted_chat[1].content}\n")

# Example 3: Few-shot prompt (with examples)
print("Example 3: Few-Shot Prompt Template")
from langchain.prompts.few_shot import FewShotPromptTemplate

examples = [
    {"input": "dog", "output": "A four-legged mammal that barks"},
    {"input": "cat", "output": "A four-legged mammal that meows"},
    {"input": "bird", "output": "A flying animal that chirps"}
]

few_shot_prompt = FewShotPromptTemplate(
    examples=examples,
    example_prompt=PromptTemplate(
        input_variables=["input"],
        template="Animal: {input}"
    ),
    suffix="Animal: {animal}\nDescription:",
    input_variables=["animal"]
)

print(f"  Few-shot examples: {len(examples)}")
print(f"  Suffix template: {few_shot_prompt.suffix}")

# ============================================================================
# SECTION 3: LANGUAGE MODELS (WITHOUT API CALLS)
# ============================================================================

print("\n" + "-"*70)
print("SECTION 3: LANGUAGE MODELS (LLMs)")
print("-"*70 + "\n")

print("LangChain supports multiple LLM providers:")
print("""
Providers:
  • OpenAI (GPT-3.5, GPT-4)
  • Anthropic (Claude)
  • Google (PaLM)
  • Cohere
  • HuggingFace
  • Ollama (local models)

Example LLM Initialization:
  from langchain.llms import OpenAI
  from langchain.chat_models import ChatOpenAI
  
  # Text completion model
  llm = OpenAI(temperature=0.7, max_tokens=100)
  
  # Chat model (better for conversations)
  chat = ChatOpenAI(model="gpt-3.5-turbo", temperature=0.7)
  
  # Invoke model
  response = llm.invoke("What is Python?")

Temperature Control:
  • 0 = Deterministic (same output every time)
  • 0.5 = Balanced (creative but consistent)
  • 1.0 = Maximum randomness (very creative)
""")

# ============================================================================
# SECTION 4: CHAINS - COMBINING COMPONENTS
# ============================================================================

print("\n" + "-"*70)
print("SECTION 4: CHAINS - COMBINING COMPONENTS")
print("-"*70 + "\n")

print("Chains sequence multiple operations together:\n")

# Example 1: LLMChain (prompt + LLM)
print("Example 1: LLMChain")
print("""
from langchain.chains import LLMChain
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate

prompt = PromptTemplate(
    input_variables=["topic"],
    template="Explain {topic} in one sentence."
)

llm = OpenAI(temperature=0.7)
chain = LLMChain(llm=llm, prompt=prompt)

result = chain.run(topic="Quantum Computing")
print(result)
""")

# Example 2: Sequential Chain
print("\nExample 2: SequentialChain (Multi-step)")
print("""
from langchain.chains import SequentialChain, LLMChain
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate

# Step 1: Generate ideas
idea_prompt = PromptTemplate(
    input_variables=["topic"],
    template="Generate 3 ideas about {topic}:"
)

# Step 2: Evaluate ideas
eval_prompt = PromptTemplate(
    input_variables=["ideas"],
    template="Evaluate these ideas:\\n{ideas}\\n\\nBest one is:"
)

llm = OpenAI()

chain1 = LLMChain(llm=llm, prompt=idea_prompt, output_key="ideas")
chain2 = LLMChain(llm=llm, prompt=eval_prompt, output_key="result")

sequential = SequentialChain(
    chains=[chain1, chain2],
    input_variables=["topic"],
    output_variables=["result"]
)

result = sequential({"topic": "AI Applications"})
""")

# Example 3: Router Chain (conditional branching)
print("\nExample 3: Router Chain (Conditional Branching)")
print("""
from langchain.chains.router import MultiPromptChain, RouterChain
from langchain.chains.router.llm_router import LLMRouterChain
from langchain.chains.router.multi_prompt_prompt import MULTI_PROMPT_ROUTER_TEMPLATE

# Define different prompts for different contexts
prompts = {
    "python": "You are a Python expert. Answer: {input}",
    "javascript": "You are a JavaScript expert. Answer: {input}",
    "general": "You are a general assistant. Answer: {input}"
}

# Router decides which prompt to use based on input
# This is useful for specialized responses based on topic
""")

# ============================================================================
# SECTION 5: MEMORY - CONVERSATION CONTEXT
# ============================================================================

print("\n" + "-"*70)
print("SECTION 5: MEMORY - CONVERSATION HISTORY")
print("-"*70 + "\n")

print("Memory types in LangChain:\n")

print("1. ConversationBufferMemory")
print("   - Stores all conversation history")
print("   - Best for: Short conversations")
print("   - Cons: Token usage grows with conversation\n")

print("2. ConversationSummaryMemory")
print("   - Summarizes conversation over time")
print("   - Best for: Long conversations")
print("   - Cons: Requires extra LLM call to summarize\n")

print("3. ConversationBufferWindowMemory")
print("   - Keeps only last K messages")
print("   - Best for: Long conversations with recent context focus")
print("   - Trade-off: Good balance\n")

print("4. EntityMemory")
print("   - Tracks entities (people, places, things)")
print("   - Best for: Complex multi-entity conversations\n")

print("Example Implementation:")
print("""
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain
from langchain.llms import OpenAI

memory = ConversationBufferMemory()

conversation = ConversationChain(
    llm=OpenAI(),
    memory=memory,
    verbose=True
)

# First message
conversation.run("Hello! What's your name?")

# Second message (remembers context)
conversation.run("What did we just talk about?")

# View memory
print(memory.buffer)
""")

# ============================================================================
# SECTION 6: AGENTS & TOOLS
# ============================================================================

print("\n" + "-"*70)
print("SECTION 6: AGENTS & TOOLS")
print("-"*70 + "\n")

print("Agents are autonomous systems that can use tools:\n")

print("How Agents Work:")
print("  1. User asks a question")
print("  2. Agent thinks about which tool to use")
print("  3. Agent calls the tool with appropriate input")
print("  4. Agent receives tool output")
print("  5. Repeat steps 2-4 until answer is complete")
print("  6. Return final answer to user\n")

print("Available Tool Categories:")
print("  • Math: Calculator, math operations")
print("  • Web: Search, scraping")
print("  • Database: SQL execution, queries")
print("  • APIs: External service calls")
print("  • Files: Document processing")
print("  • Custom: User-defined functions\n")

print("Example Agent with Tools:")
print("""
from langchain.agents import Tool, initialize_agent, AgentType
from langchain.llms import OpenAI
from langchain.tools import tool
import math

# Define custom tools
@tool
def calculator(expression: str) -> float:
    '''Evaluates mathematical expressions'''
    return eval(expression)

@tool
def get_weather(location: str) -> str:
    '''Get weather for a location (mock implementation)'''
    return f"Weather in {location}: Sunny, 72°F"

tools = [
    Tool(
        name="Calculator",
        func=calculator,
        description="Useful for math calculations"
    ),
    Tool(
        name="Weather",
        func=get_weather,
        description="Get current weather for a location"
    )
]

# Create agent
agent = initialize_agent(
    tools=tools,
    llm=OpenAI(),
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True
)

# Use agent
result = agent.run("What is 5 * 10? And what's the weather in NYC?")
print(result)
""")

# ============================================================================
# SECTION 7: DOCUMENT LOADING & Q&A
# ============================================================================

print("\n" + "-"*70)
print("SECTION 7: DOCUMENT LOADING & Q&A SYSTEMS")
print("-"*70 + "\n")

print("Document Processing Pipeline:\n")
print("  1. Load Documents (from various formats)")
print("  2. Split into Chunks (manageable pieces)")
print("  3. Create Embeddings (semantic representation)")
print("  4. Store in Vector DB (for similarity search)")
print("  5. Retrieve Relevant Chunks (based on query)")
print("  6. Generate Answer (using retrieved context)\n")

print("Supported Document Loaders:")
print("""
Document Formats:
  • PDF: PyPDF2Loader, PDFMinerLoader
  • TXT: TextLoader
  • CSV: CSVLoader
  • JSON: JSONLoader
  • HTML: UnstructuredHTMLLoader
  • Markdown: UnstructuredMarkdownLoader
  • Word: UnstructuredWordDocumentLoader
  • Web: WebBaseLoader
  • YouTube: YoutubeLoader
  • Directory: DirectoryLoader (multiple files)
""")

print("Example Document Q&A:")
print("""
from langchain.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings
from langchain.chains import RetrievalQA
from langchain.llms import OpenAI

# 1. Load document
loader = TextLoader("document.txt")
documents = loader.load()

# 2. Split into chunks
splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
chunks = splitter.split_documents(documents)

# 3. Create embeddings and vector store
embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_documents(chunks, embeddings)

# 4. Create Q&A chain
qa_chain = RetrievalQA.from_chain_type(
    llm=OpenAI(),
    chain_type="stuff",
    retriever=vectorstore.as_retriever()
)

# 5. Ask questions
result = qa_chain.run("What is the main topic?")
print(result)
""")

# ============================================================================
# SECTION 8: TEXT SPLITTERS (CHUNKING STRATEGIES)
# ============================================================================

print("\n" + "-"*70)
print("SECTION 8: TEXT SPLITTERS (CHUNKING STRATEGIES)")
print("-"*70 + "\n")

from langchain.text_splitter import CharacterTextSplitter, RecursiveCharacterTextSplitter

# Example text
sample_text = """LangChain is a framework for developing applications powered by language models.
It enables applications that are: Data-aware, Connected to other sources of data, Agentic.
LangChain provides the building blocks for applications to be Autonomous."""

print("Example 1: CharacterTextSplitter")
splitter = CharacterTextSplitter(chunk_size=50, chunk_overlap=10)
chunks = splitter.split_text(sample_text)
print(f"  Text split into {len(chunks)} chunks")
for i, chunk in enumerate(chunks):
    print(f"  Chunk {i+1}: {chunk[:40]}...")

print("\nExample 2: RecursiveCharacterTextSplitter")
recursive_splitter = RecursiveCharacterTextSplitter(
    separators=["\n\n", "\n", " ", ""],
    chunk_size=50,
    chunk_overlap=10
)
recursive_chunks = recursive_splitter.split_text(sample_text)
print(f"  Text split into {len(recursive_chunks)} chunks")
for i, chunk in enumerate(recursive_chunks):
    print(f"  Chunk {i+1}: {chunk[:40]}...")

# ============================================================================
# SECTION 9: EMBEDDINGS & VECTORSTORES
# ============================================================================

print("\n" + "-"*70)
print("SECTION 9: EMBEDDINGS & VECTORSTORES")
print("-"*70 + "\n")

print("What are Embeddings?")
print("  Embeddings convert text into numerical vectors")
print("  Similar texts have similar vector representations")
print("  Used for semantic search and similarity comparison\n")

print("Embedding Providers:")
print("""
  • OpenAI Embeddings (text-embedding-3-small, text-embedding-3-large)
  • HuggingFace Embeddings
  • Cohere Embeddings
  • Ollama (local)
  • Custom embeddings

Vector Store Implementations:
  • FAISS (Facebook AI Similarity Search)
  • Pinecone (cloud-based)
  • Chroma (in-memory)
  • Weaviate (graph-based)
  • Milvus (open-source)
  • Redis (with RediSearch)
  • Elasticsearch
  • Qdrant
  
Key Operations:
  • add_documents() - Add docs to store
  • similarity_search() - Find similar docs
  • max_marginal_relevance_search() - Diverse results
  • as_retriever() - Convert to retriever for chains
""")

# ============================================================================
# SECTION 10: COOL FEATURES & ADVANCED PATTERNS
# ============================================================================

print("\n" + "-"*70)
print("SECTION 10: COOL FEATURES & ADVANCED PATTERNS")
print("-"*70 + "\n")

print("1. STREAMING")
print("""
Get real-time token streaming instead of waiting for full response:

from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

llm = OpenAI(callbacks=[StreamingStdOutCallbackHandler()])
llm.invoke("Explain quantum computing")  # Streams as tokens arrive
""")

print("\n2. CALLBACK HANDLERS")
print("""
Execute custom code at different points in chain execution:

from langchain.callbacks.base import BaseCallbackHandler

class MyCallback(BaseCallbackHandler):
    def on_llm_start(self, serialized, prompts, **kwargs):
        print(f"Starting LLM with prompt: {prompts[0]}")
    
    def on_llm_end(self, response, **kwargs):
        print(f"LLM finished with output: {response}")

chain.run("Hello", callbacks=[MyCallback()])
""")

print("\n3. CACHING")
print("""
Cache LLM responses to avoid duplicate API calls:

from langchain.cache import InMemoryCache, SQLiteCache
import langchain

# In-memory cache
langchain.llm_cache = InMemoryCache()

# Or SQLite cache
langchain.llm_cache = SQLiteCache(database_path=".langchain.db")

# Exact same prompt = cached response (no API call)
llm.invoke("What is 2+2?")  # API call
llm.invoke("What is 2+2?")  # Cached response
""")

print("\n4. OUTPUT PARSING")
print("""
Ensure consistent, structured output:

from langchain.output_parsers import StructuredOutputParser, ResponseSchema

schemas = [
    ResponseSchema(name="person", description="Name of the person"),
    ResponseSchema(name="age", description="Age of the person")
]

parser = StructuredOutputParser.from_response_schemas(schemas)

# Ensures output is parsed into structured format
result = parser.parse(llm_output)
print(result['person'], result['age'])
""")

print("\n5. EVALUATION")
print("""
Evaluate chain performance with LLMEval:

from langchain.evaluation import load_evaluator

evaluator = load_evaluator("qa")
result = evaluator.evaluate_strings(
    prediction="Paris",
    reference="The capital of France is Paris",
    input="What is the capital of France?"
)

print(result['score'])  # 0.0 to 1.0
""")

print("\n6. SQL CHAINS")
print("""
Interact with SQL databases:

from langchain.sql_database import SQLDatabase
from langchain.chains import create_sql_agent

db = SQLDatabase.from_uri("sqlite:///my_database.db")
agent_executor = create_sql_agent(
    llm=OpenAI(),
    toolkit=SQLDatabaseToolkit(db=db),
    verbose=True
)

result = agent_executor.run("How many users are in the database?")
""")

print("\n7. CUSTOM TOOLS")
print("""
Create custom tools for agents:

from langchain.tools import tool

@tool
def my_custom_tool(input_str: str) -> str:
    '''Description of what this tool does'''
    return f"Processed: {input_str}"

# Use with agent
agent = initialize_agent(
    tools=[my_custom_tool],
    llm=OpenAI()
)
""")

print("\n8. STREAMING RESPONSES")
print("""
Stream outputs for real-time UI updates:

for token in llm.stream("Tell me a story"):
    print(token, end="", flush=True)  # Real-time output
""")

print("\n9. RETRY LOGIC")
print("""
Automatic retry with exponential backoff:

from langchain.llms.base import LLM
from langchain.callbacks.manager import Callbacks

llm = OpenAI(max_retries=3)  # Retry up to 3 times
""")

print("\n10. SUMMARIZATION")
print("""
Summarize long documents:

from langchain.chains.summarize import load_summarize_chain

chain = load_summarize_chain(OpenAI(), chain_type="map_reduce")
result = chain.run(documents)  # Summarized output
""")

# ============================================================================
# SECTION 11: COMMON PATTERNS & RECIPES
# ============================================================================

print("\n" + "-"*70)
print("SECTION 11: COMMON PATTERNS & RECIPES")
print("-"*70 + "\n")

print("Pattern 1: Chat Application")
print("""
from langchain.chat_models import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

chat = ChatOpenAI()
memory = ConversationBufferMemory()

conversation = ConversationChain(
    llm=chat,
    memory=memory,
    verbose=True
)

while True:
    user_input = input("You: ")
    response = conversation.run(input=user_input)
    print(f"AI: {response}")
""")

print("\nPattern 2: Document Search & QA")
print("""
# Load docs → Create embeddings → Store vectors
# User query → Search similar docs → Generate answer
# Perfect for: PDF Q&A, knowledge bases, documentation
""")

print("\nPattern 3: Agentic Workflow")
print("""
# Agent uses tools iteratively
# Great for: Complex tasks, multi-step processes
# Examples: Research, calculations, API calls
""")

print("\nPattern 4: Pipeline with Multiple LLMs")
print("""
# Use different models for different tasks
# E.g., Fast model for routing, powerful model for reasoning
""")

# ============================================================================
# SECTION 12: USEFUL RESOURCES & NEXT STEPS
# ============================================================================

print("\n" + "-"*70)
print("SECTION 12: USEFUL RESOURCES & NEXT STEPS")
print("-"*70 + "\n")

print("Official Documentation:")
print("  📚 https://python.langchain.com/")
print("  🔗 https://github.com/langchain-ai/langchain\n")

print("Key Modules to Explore:")
print("  • langchain.llms - LLM interfaces")
print("  • langchain.chat_models - Chat model interfaces")
print("  • langchain.prompts - Prompt management")
print("  • langchain.chains - Chain implementations")
print("  • langchain.agents - Agent implementations")
print("  • langchain.memory - Memory management")
print("  • langchain.vectorstores - Vector store implementations")
print("  • langchain.document_loaders - Document loading")
print("  • langchain.tools - Built-in and custom tools")
print("  • langchain.callbacks - Callback handlers\n")

print("Common Use Cases:")
print("  ✓ Chatbots & conversational AI")
print("  ✓ Document Q&A systems")
print("  ✓ Code analysis & generation")
print("  ✓ Research assistants")
print("  ✓ Data analysis pipelines")
print("  ✓ Content generation")
print("  ✓ Customer support automation")
print("  ✓ Knowledge base search\n")

print("Tips for Production:")
print("  • Use appropriate temperature (0 for deterministic)")
print("  • Implement error handling and retries")
print("  • Cache responses to reduce API costs")
print("  • Monitor token usage")
print("  • Use appropriate models (faster/cheaper for routine tasks)")
print("  • Implement user feedback loops")
print("  • Version your prompts")
print("  • Test with multiple inputs")

print("\n" + "="*70)
print("END OF LANGCHAIN PLAYGROUND")
print("="*70 + "\n")

print("💡 TIP: To run the examples with API calls, set your OPENAI_API_KEY")
print("         and uncomment the example code sections above.\n")
