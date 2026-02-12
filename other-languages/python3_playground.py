#!/usr/bin/env python3
"""
Python3 Playground: Variables, Conditions, Aggregations, Looping & OOP
Comprehensive guide with examples and comments
"""

# ============================================================================
# SECTION 1: VARIABLE DECLARATIONS & DATA TYPES
# ============================================================================

print("\n" + "="*60)
print("SECTION 1: VARIABLE DECLARATIONS & DATA TYPES")
print("="*60 + "\n")

# Integer variables (whole numbers)
age = 25
count = 100
negative_number = -42
print(f"Integers - age: {age}, count: {count}, negative: {negative_number}")

# Float variables (decimal numbers)
height = 5.9
pi = 3.14159
temperature = -273.15
print(f"Floats - height: {height}, pi: {pi}, temperature: {temperature}")

# String variables (text)
name = "John Doe"
message = 'Single quotes also work'
multiline = """This is a
multiline string"""
print(f"Strings - name: {name}")
print(f"Multiline:\n{multiline}")

# Boolean variables (True/False)
is_developer = True
is_student = False
print(f"Booleans - is_developer: {is_developer}, is_student: {is_student}")

# List variables (ordered, mutable collection)
numbers = [1, 2, 3, 4, 5]
mixed_list = [1, "hello", 3.14, True]
print(f"Lists - numbers: {numbers}, mixed: {mixed_list}")

# Tuple variables (ordered, immutable collection)
coordinates = (10, 20, 30)
colors = ("red", "green", "blue")
print(f"Tuples - coordinates: {coordinates}, colors: {colors}")

# Dictionary variables (key-value pairs)
person = {"name": "Alice", "age": 30, "city": "NYC"}
scores = {"math": 95, "english": 87, "science": 92}
print(f"Dictionaries - person: {person}")

# Set variables (unordered, unique elements)
unique_numbers = {1, 2, 3, 4, 5}
tags = {"python", "programming", "tutorial"}
print(f"Sets - numbers: {unique_numbers}, tags: {tags}")

# Type checking with type()
print(f"\nType checking:")
print(f"  type(age) = {type(age)}")
print(f"  type(height) = {type(height)}")
print(f"  type(name) = {type(name)}")
print(f"  type(numbers) = {type(numbers)}")

# Type conversion/casting
string_number = "42"
converted_to_int = int(string_number)
converted_to_float = float(string_number)
converted_to_str = str(100)
print(f"\nType conversion:")
print(f"  str '42' to int: {converted_to_int}, type: {type(converted_to_int)}")
print(f"  str '42' to float: {converted_to_float}, type: {type(converted_to_float)}")

# ============================================================================
# SECTION 2: CONDITIONS & CONTROL FLOW
# ============================================================================

print("\n" + "="*60)
print("SECTION 2: CONDITIONS & CONTROL FLOW")
print("="*60 + "\n")

# Basic if-elif-else statement
age = 25
if age < 13:
    category = "Child"
elif age < 18:
    category = "Teenager"
elif age < 65:
    category = "Adult"
else:
    category = "Senior"
print(f"Age {age}: {category}")

# Comparison operators
x, y = 10, 20
print(f"\nComparison operators:")
print(f"  {x} == {y}: {x == y}")  # Equal
print(f"  {x} != {y}: {x != y}")  # Not equal
print(f"  {x} < {y}: {x < y}")    # Less than
print(f"  {x} > {y}: {x > y}")    # Greater than
print(f"  {x} <= {y}: {x <= y}")  # Less than or equal
print(f"  {x} >= {y}: {x >= y}")  # Greater than or equal

# Logical operators (and, or, not)
print(f"\nLogical operators:")
condition1 = age > 18 and age < 65
condition2 = age < 13 or age > 65
condition3 = not (age == 25)
print(f"  age > 18 AND age < 65: {condition1}")
print(f"  age < 13 OR age > 65: {condition2}")
print(f"  NOT (age == 25): {condition3}")

# Ternary operator (one-liner if-else)
status = "Adult" if age >= 18 else "Minor"
print(f"\nTernary operator: status = {status}")

# in/not in operator
fruits = ["apple", "banana", "cherry"]
print(f"\nMembership operators:")
print(f"  'apple' in {fruits}: {'apple' in fruits}")
print(f"  'grape' in {fruits}: {'grape' in fruits}")
print(f"  'grape' not in {fruits}: {'grape' not in fruits}")

# Switch-like behavior with dictionary
print(f"\nSwitch-like pattern with dictionary:")
grade = 'B'
grade_meanings = {
    'A': 'Excellent',
    'B': 'Good',
    'C': 'Average',
    'D': 'Below Average',
    'F': 'Fail'
}
print(f"  Grade {grade}: {grade_meanings.get(grade, 'Unknown')}")

# ============================================================================
# SECTION 3: LOOPING & ITERATION
# ============================================================================

print("\n" + "="*60)
print("SECTION 3: LOOPING & ITERATION")
print("="*60 + "\n")

# For loop with range (start, stop, step)
print("For loop with range:")
print("  range(5):", end=" ")
for i in range(5):
    print(i, end=" ")
print()

print("  range(2, 8):", end=" ")
for i in range(2, 8):
    print(i, end=" ")
print()

print("  range(0, 10, 2):", end=" ")
for i in range(0, 10, 2):
    print(i, end=" ")
print()

# For loop over list/iterable
print(f"\nFor loop over list:")
fruits = ["apple", "banana", "cherry", "date"]
for fruit in fruits:
    print(f"  {fruit}")

# Enumerate - get index and value
print(f"\nEnumerate (index and value):")
for index, fruit in enumerate(fruits):
    print(f"  [{index}] {fruit}")

# For loop over dictionary
print(f"\nFor loop over dictionary:")
person = {"name": "Alice", "age": 30, "city": "NYC"}
for key, value in person.items():
    print(f"  {key}: {value}")

# While loop
print(f"\nWhile loop:")
print("  Countdown:", end=" ")
count = 3
while count > 0:
    print(count, end=" ")
    count -= 1
print("Blast off!")

# Break statement (exit loop early)
print(f"\nBreak statement:")
print("  Numbers before 5:", end=" ")
for i in range(10):
    if i == 5:
        break
    print(i, end=" ")
print()

# Continue statement (skip to next iteration)
print(f"\nContinue statement:")
print("  Skip 3:", end=" ")
for i in range(6):
    if i == 3:
        continue
    print(i, end=" ")
print()

# Nested loops
print(f"\nNested loops (times table):")
for i in range(1, 4):
    for j in range(1, 4):
        print(f"{i}*{j}={i*j:2d}", end="  ")
    print()

# ============================================================================
# SECTION 4: AGGREGATIONS & TRANSFORMATIONS
# ============================================================================

print("\n" + "="*60)
print("SECTION 4: AGGREGATIONS & TRANSFORMATIONS")
print("="*60 + "\n")

numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Sum aggregation
total = sum(numbers)
print(f"Sum of {numbers}: {total}")

# Count aggregation
count = len(numbers)
print(f"Count: {count}")

# Average (mean)
average = sum(numbers) / len(numbers)
print(f"Average: {average:.2f}")

# Min and Max
print(f"Min: {min(numbers)}, Max: {max(numbers)}")

# List comprehension - transform each element
squares = [x**2 for x in numbers]
print(f"\nList comprehension (squares): {squares}")

# List comprehension with filter
even_numbers = [x for x in numbers if x % 2 == 0]
odd_numbers = [x for x in numbers if x % 2 != 0]
print(f"Even numbers: {even_numbers}")
print(f"Odd numbers: {odd_numbers}")

# Dictionary comprehension
numbers_dict = {x: x**2 for x in range(1, 6)}
print(f"\nDictionary comprehension: {numbers_dict}")

# Map function - apply function to all elements
doubled = list(map(lambda x: x * 2, numbers))
print(f"\nMap (doubled): {doubled}")

# Filter function - keep elements matching condition
greater_than_5 = list(filter(lambda x: x > 5, numbers))
print(f"Filter (> 5): {greater_than_5}")

# Reduce - aggregate to single value
from functools import reduce
product = reduce(lambda x, y: x * y, [1, 2, 3, 4, 5])
print(f"Reduce (product of 1-5): {product}")

# Grouping
print(f"\nGrouping by odd/even:")
grouped = {}
for num in numbers:
    key = "even" if num % 2 == 0 else "odd"
    if key not in grouped:
        grouped[key] = []
    grouped[key].append(num)
print(f"  {grouped}")

# Sorting
unsorted = [3, 1, 4, 1, 5, 9, 2, 6, 5]
print(f"\nSorting:")
print(f"  Original: {unsorted}")
print(f"  Ascending: {sorted(unsorted)}")
print(f"  Descending: {sorted(unsorted, reverse=True)}")

# ============================================================================
# SECTION 5: SIMPLE OBJECT-ORIENTED PROGRAMMING (OOP)
# ============================================================================

print("\n" + "="*60)
print("SECTION 5: OBJECT-ORIENTED PROGRAMMING (OOP)")
print("="*60 + "\n")

# Basic class definition
class Animal:
    """A simple animal class"""
    
    # Class variable (shared by all instances)
    kingdom = "Animalia"
    
    def __init__(self, name, species):
        """Constructor - initializes instance variables"""
        self.name = name
        self.species = species
        self.age = 0
    
    def describe(self):
        """Instance method"""
        return f"{self.name} is a {self.species}"
    
    def age_one_year(self):
        """Increment age"""
        self.age += 1
        return f"{self.name} is now {self.age} years old"
    
    def __str__(self):
        """String representation"""
        return f"Animal: {self.name} ({self.species})"

# Create and use instances
print("Creating animal instances:")
dog = Animal("Buddy", "Dog")
cat = Animal("Whiskers", "Cat")

print(f"  {dog.describe()}")
print(f"  {cat.describe()}")
print(f"  {dog.age_one_year()}")
print(f"  {dog.age_one_year()}")
print(f"  String representation: {dog}")

# Inheritance - create specialized classes
print(f"\nInheritance:")

class Vehicle:
    """Base vehicle class"""
    def __init__(self, brand, model):
        self.brand = brand
        self.model = model
        self.speed = 0
    
    def accelerate(self, amount):
        self.speed += amount
        return f"{self.brand} {self.model} is now at {self.speed} km/h"
    
    def info(self):
        return f"{self.brand} {self.model}"

class Car(Vehicle):
    """Car inherits from Vehicle"""
    def __init__(self, brand, model, num_doors):
        super().__init__(brand, model)  # Call parent constructor
        self.num_doors = num_doors
    
    def info(self):
        """Override parent method"""
        return f"{super().info()} with {self.num_doors} doors"

class Motorcycle(Vehicle):
    """Motorcycle inherits from Vehicle"""
    def __init__(self, brand, model, has_sidecar):
        super().__init__(brand, model)
        self.has_sidecar = has_sidecar

my_car = Car("Toyota", "Camry", 4)
my_bike = Motorcycle("Harley", "Street 750", False)

print(f"  {my_car.info()}")
print(f"  {my_car.accelerate(50)}")
print(f"  {my_bike.info()}")

# Polymorphism - same method, different implementations
print(f"\nPolymorphism:")

class Bird:
    def make_sound(self):
        return "Generic sound"

class Duck(Bird):
    def make_sound(self):
        return "Quack!"

class Owl(Bird):
    def make_sound(self):
        return "Hoo hoo!"

birds = [Duck(), Owl(), Bird()]
print(f"  Different sounds from different birds:")
for bird in birds:
    print(f"    {bird.__class__.__name__}: {bird.make_sound()}")

# Encapsulation - private attributes
print(f"\nEncapsulation (private attributes):")

class BankAccount:
    """Demonstrates encapsulation with private attributes"""
    def __init__(self, owner, balance):
        self.owner = owner
        self.__balance = balance  # Private attribute (name mangling)
    
    def deposit(self, amount):
        if amount > 0:
            self.__balance += amount
            return f"Deposited ${amount}. Balance: ${self.__balance}"
        return "Invalid amount"
    
    def withdraw(self, amount):
        if amount > 0 and amount <= self.__balance:
            self.__balance -= amount
            return f"Withdrew ${amount}. Balance: ${self.__balance}"
        return "Insufficient funds"
    
    def get_balance(self):
        """Getter method for private attribute"""
        return self.__balance

account = BankAccount("John", 1000)
print(f"  {account.deposit(500)}")
print(f"  {account.withdraw(200)}")
print(f"  Balance: ${account.get_balance()}")

# ============================================================================
# SECTION 6: COOL FEATURES & ADVANCED CONCEPTS
# ============================================================================

print("\n" + "="*60)
print("SECTION 6: COOL FEATURES & ADVANCED CONCEPTS")
print("="*60 + "\n")

# 1. Lambda functions (anonymous functions)
print("1. Lambda functions:")
multiply = lambda x, y: x * y
print(f"   Lambda multiply(5, 3) = {multiply(5, 3)}")

# 2. Generator functions (memory efficient)
print(f"\n2. Generator functions:")
def countdown(n):
    """Generator that counts down"""
    while n > 0:
        yield n
        n -= 1

print(f"   Countdown: {list(countdown(5))}")

# 3. Decorators (modify function behavior)
print(f"\n3. Decorators:")
def uppercase_decorator(func):
    def wrapper(*args):
        result = func(*args)
        return result.upper()
    return wrapper

@uppercase_decorator
def greet(name):
    return f"hello, {name}!"

print(f"   {greet('alice')}")

# 4. Exception handling (try-except)
print(f"\n4. Exception handling:")
try:
    result = 10 / 0
except ZeroDivisionError:
    print(f"   Caught: Cannot divide by zero")
except Exception as e:
    print(f"   Caught: {e}")
finally:
    print(f"   Cleanup code always runs")

# 5. Context manager (with statement)
print(f"\n5. Context Manager:")
class MyContext:
    def __enter__(self):
        print(f"   Entering context")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"   Exiting context")

with MyContext() as ctx:
    print(f"   Inside context block")

# 6. Type hints (documentation)
print(f"\n6. Type hints:")
def add(x: int, y: int) -> int:
    """Add two integers"""
    return x + y

print(f"   add(3, 4) = {add(3, 4)}")

# 7. Multiple assignment and unpacking
print(f"\n7. Unpacking:")
a, b, c = 1, 2, 3
x, y = [10, 20]
name, age = ("Alice", 30)
print(f"   a={a}, b={b}, c={c}")
print(f"   x={x}, y={y}")
print(f"   name={name}, age={age}")

# 8. *args and **kwargs
print(f"\n8. *args and **kwargs:")
def flexible_function(*args, **kwargs):
    print(f"   args (positional): {args}")
    print(f"   kwargs (named): {kwargs}")

flexible_function(1, 2, 3, name="Alice", age=30)

# 9. String formatting (f-strings)
print(f"\n9. String formatting:")
name = "Bob"
age = 25
height = 5.9
print(f"   f-string: {name} is {age} years old, {height}m tall")
print(f"   Formatted: {name} is {age:03d} years old, {height:.1f}m tall")

# 10. Set operations
print(f"\n10. Set operations:")
set_a = {1, 2, 3, 4, 5}
set_b = {4, 5, 6, 7, 8}
print(f"   Set A: {set_a}")
print(f"   Set B: {set_b}")
print(f"   Union: {set_a | set_b}")
print(f"   Intersection: {set_a & set_b}")
print(f"   Difference: {set_a - set_b}")

print("\n" + "="*60)
print("END OF PYTHON3 PLAYGROUND")
print("="*60 + "\n")
