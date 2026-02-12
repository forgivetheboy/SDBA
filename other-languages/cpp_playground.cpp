// ============================================================================
// C++ Playground: Variables, Conditions, Aggregations, Looping & OOP
// Comprehensive guide with examples and comments
// Compile: g++ -std=c++17 cpp_playground.cpp -o cpp_playground
// ============================================================================

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <numeric>
#include <iomanip>
using namespace std;

// ============================================================================
// SECTION 1: VARIABLE DECLARATIONS & DATA TYPES
// ============================================================================

void section_variables() {
    cout << "\n" << string(60, '=') << endl;
    cout << "SECTION 1: VARIABLE DECLARATIONS & DATA TYPES" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    // Integer types
    int age = 25;              // Standard integer
    short small_num = 100;     // Smaller range integer
    long large_num = 1000000;  // Larger range integer
    unsigned int count = 50;   // Only positive values
    cout << "Integers:" << endl;
    cout << "  age (int): " << age << endl;
    cout << "  small_num (short): " << small_num << endl;
    cout << "  large_num (long): " << large_num << endl;
    cout << "  count (unsigned int): " << count << endl;
    
    // Floating point types
    float height = 5.9f;           // Single precision (6-7 digits)
    double pi = 3.14159265359;     // Double precision (15-17 digits)
    long double precise = 3.141592653589793238L;  // Extended precision
    cout << "\nFloating point:" << endl;
    cout << "  height (float): " << height << endl;
    cout << "  pi (double): " << pi << endl;
    cout << "  precise (long double): " << precise << endl;
    
    // Character type
    char letter = 'A';
    char digit = '5';
    cout << "\nCharacter:" << endl;
    cout << "  letter (char): " << letter << endl;
    cout << "  digit (char): " << digit << endl;
    
    // Boolean type
    bool is_developer = true;
    bool is_student = false;
    cout << "\nBoolean:" << endl;
    cout << "  is_developer (bool): " << (is_developer ? "true" : "false") << endl;
    cout << "  is_student (bool): " << (is_student ? "true" : "false") << endl;
    
    // String type
    string name = "John Doe";
    string message = "Hello World";
    cout << "\nString:" << endl;
    cout << "  name (string): " << name << endl;
    cout << "  message (string): " << message << endl;
    
    // Arrays (fixed size)
    int numbers[5] = {1, 2, 3, 4, 5};
    cout << "\nArray (fixed size):" << endl;
    cout << "  int numbers[5]: ";
    for (int num : numbers) cout << num << " ";
    cout << endl;
    
    // Vectors (dynamic arrays)
    vector<int> dynamic_numbers = {1, 2, 3, 4, 5};
    vector<string> fruits = {"apple", "banana", "cherry"};
    cout << "\nVector (dynamic array):" << endl;
    cout << "  vector<int>: ";
    for (int num : dynamic_numbers) cout << num << " ";
    cout << endl;
    cout << "  vector<string>: ";
    for (const auto& fruit : fruits) cout << fruit << " ";
    cout << endl;
    
    // Constants
    const int MAX_USERS = 100;
    const double PI = 3.14159;
    cout << "\nConstants:" << endl;
    cout << "  const int MAX_USERS: " << MAX_USERS << endl;
    cout << "  const double PI: " << PI << endl;
}

// ============================================================================
// SECTION 2: CONDITIONS & CONTROL FLOW
// ============================================================================

void section_conditions() {
    cout << "\n" << string(60, '=') << endl;
    cout << "SECTION 2: CONDITIONS & CONTROL FLOW" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    // Basic if-else
    int age = 25;
    if (age < 13) {
        cout << "Child" << endl;
    } else if (age < 18) {
        cout << "Teenager" << endl;
    } else if (age < 65) {
        cout << "Adult" << endl;
    } else {
        cout << "Senior" << endl;
    }
    
    // Comparison operators
    int x = 10, y = 20;
    cout << "\nComparison operators:" << endl;
    cout << "  " << x << " == " << y << ": " << (x == y) << endl;
    cout << "  " << x << " != " << y << ": " << (x != y) << endl;
    cout << "  " << x << " < " << y << ": " << (x < y) << endl;
    cout << "  " << x << " > " << y << ": " << (x > y) << endl;
    cout << "  " << x << " <= " << y << ": " << (x <= y) << endl;
    cout << "  " << x << " >= " << y << ": " << (x >= y) << endl;
    
    // Logical operators
    cout << "\nLogical operators:" << endl;
    cout << "  age > 18 && age < 65: " << ((age > 18 && age < 65) ? "true" : "false") << endl;
    cout << "  age < 13 || age > 65: " << ((age < 13 || age > 65) ? "true" : "false") << endl;
    cout << "  !(age == 25): " << (!(age == 25) ? "true" : "false") << endl;
    
    // Ternary operator
    string status = (age >= 18) ? "Adult" : "Minor";
    cout << "\nTernary operator:" << endl;
    cout << "  status: " << status << endl;
    
    // Switch statement
    char grade = 'B';
    switch (grade) {
        case 'A': cout << "\nSwitch: Excellent"; break;
        case 'B': cout << "\nSwitch: Good"; break;
        case 'C': cout << "\nSwitch: Average"; break;
        default: cout << "\nSwitch: Unknown";
    }
    cout << endl;
}

// ============================================================================
// SECTION 3: LOOPING & ITERATION
// ============================================================================

void section_looping() {
    cout << "\n" << string(60, '=') << endl;
    cout << "SECTION 3: LOOPING & ITERATION" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    // For loop with range
    cout << "For loop (0-4): ";
    for (int i = 0; i < 5; i++) {
        cout << i << " ";
    }
    cout << endl;
    
    // For loop with step
    cout << "For loop (0-10, step 2): ";
    for (int i = 0; i <= 10; i += 2) {
        cout << i << " ";
    }
    cout << endl;
    
    // Range-based for loop (C++11)
    vector<string> fruits = {"apple", "banana", "cherry"};
    cout << "Range-based for: ";
    for (const auto& fruit : fruits) {
        cout << fruit << " ";
    }
    cout << endl;
    
    // For loop with index and value
    cout << "For with index:" << endl;
    for (size_t i = 0; i < fruits.size(); i++) {
        cout << "  [" << i << "] " << fruits[i] << endl;
    }
    
    // While loop
    cout << "\nWhile loop (countdown): ";
    int count = 3;
    while (count > 0) {
        cout << count << " ";
        count--;
    }
    cout << "Blast off!" << endl;
    
    // Do-while loop
    cout << "Do-while loop: ";
    int x = 1;
    do {
        cout << x << " ";
        x++;
    } while (x <= 3);
    cout << endl;
    
    // Break statement
    cout << "Break (stop at 5): ";
    for (int i = 0; i < 10; i++) {
        if (i == 5) break;
        cout << i << " ";
    }
    cout << endl;
    
    // Continue statement
    cout << "Continue (skip 3): ";
    for (int i = 0; i < 6; i++) {
        if (i == 3) continue;
        cout << i << " ";
    }
    cout << endl;
    
    // Nested loops
    cout << "\nNested loops (3x3 table):" << endl;
    for (int i = 1; i <= 3; i++) {
        for (int j = 1; j <= 3; j++) {
            cout << i << "x" << j << "=" << (i*j) << "  ";
        }
        cout << endl;
    }
}

// ============================================================================
// SECTION 4: AGGREGATIONS & TRANSFORMATIONS
// ============================================================================

void section_aggregations() {
    cout << "\n" << string(60, '=') << endl;
    cout << "SECTION 4: AGGREGATIONS & TRANSFORMATIONS" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    vector<int> numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Sum
    int total = accumulate(numbers.begin(), numbers.end(), 0);
    cout << "Sum: " << total << endl;
    
    // Count
    int count = numbers.size();
    cout << "Count: " << count << endl;
    
    // Average
    double average = static_cast<double>(total) / count;
    cout << "Average: " << average << endl;
    
    // Min and Max
    int min_val = *min_element(numbers.begin(), numbers.end());
    int max_val = *max_element(numbers.begin(), numbers.end());
    cout << "Min: " << min_val << ", Max: " << max_val << endl;
    
    // Transform (apply function to all elements)
    vector<int> squared(numbers.size());
    transform(numbers.begin(), numbers.end(), squared.begin(), 
              [](int x) { return x * x; });
    cout << "Squared: ";
    for (int num : squared) cout << num << " ";
    cout << endl;
    
    // Filter (keep elements matching condition)
    vector<int> evens;
    for (int num : numbers) {
        if (num % 2 == 0) evens.push_back(num);
    }
    cout << "Even numbers: ";
    for (int num : evens) cout << num << " ";
    cout << endl;
    
    // Sorting
    vector<int> unsorted = {3, 1, 4, 1, 5, 9, 2, 6, 5};
    vector<int> ascending = unsorted;
    vector<int> descending = unsorted;
    
    sort(ascending.begin(), ascending.end());
    sort(descending.begin(), descending.end(), greater<int>());
    
    cout << "\nSorting:" << endl;
    cout << "  Original: ";
    for (int num : unsorted) cout << num << " ";
    cout << endl;
    cout << "  Ascending: ";
    for (int num : ascending) cout << num << " ";
    cout << endl;
    cout << "  Descending: ";
    for (int num : descending) cout << num << " ";
    cout << endl;
}

// ============================================================================
// SECTION 5: OBJECT-ORIENTED PROGRAMMING (OOP)
// ============================================================================

// Basic class definition
class Animal {
private:
    int age;

protected:
    string name;
    string species;

public:
    // Class variable
    static string kingdom;
    
    // Constructor
    Animal(string n, string s) : name(n), species(s), age(0) {}
    
    // Getter
    string get_name() const { return name; }
    
    // Method
    string describe() const {
        return name + " is a " + species + " (" + kingdom + ")";
    }
    
    // Another method
    void age_one_year() {
        age++;
        cout << name << " is now " << age << " years old" << endl;
    }
    
    // Virtual destructor for polymorphism
    virtual ~Animal() {}
};

// Initialize static member
string Animal::kingdom = "Animalia";

// Inheritance - derived class
class Dog : public Animal {
private:
    string breed;

public:
    Dog(string n, string b) : Animal(n, "Dog"), breed(b) {}
    
    string get_breed() const { return breed; }
};

// Another derived class
class Bird : public Animal {
private:
    bool can_fly;

public:
    Bird(string n, bool fly) : Animal(n, "Bird"), can_fly(fly) {}
    
    virtual string make_sound() const {
        return "Generic bird sound";
    }
};

// Polymorphism - derived class overrides method
class Duck : public Bird {
public:
    Duck(string n) : Bird(n, true) {}
    
    string make_sound() const override {
        return "Quack!";
    }
};

class Owl : public Bird {
public:
    Owl(string n) : Bird(n, true) {}
    
    string make_sound() const override {
        return "Hoo hoo!";
    }
};

void section_oop() {
    cout << "\n" << string(60, '=') << endl;
    cout << "SECTION 5: OBJECT-ORIENTED PROGRAMMING (OOP)" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    // Create objects
    cout << "Creating objects:" << endl;
    Dog dog("Buddy", "Golden Retriever");
    cout << "  " << dog.describe() << endl;
    cout << "  Breed: " << dog.get_breed() << endl;
    dog.age_one_year();
    
    // Polymorphism
    cout << "\nPolymorphism:" << endl;
    Bird* birds[] = {
        new Duck("Donald"),
        new Owl("Oliver"),
        new Bird("Generic")
    };
    
    for (int i = 0; i < 3; i++) {
        cout << "  " << birds[i]->make_sound() << endl;
        delete birds[i];
    }
}

// ============================================================================
// SECTION 6: COOL FEATURES
// ============================================================================

void section_cool_features() {
    cout << "\n" << string(60, '=') << endl;
    cout << "SECTION 6: COOL FEATURES" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    // 1. Lambda functions
    cout << "1. Lambda functions:" << endl;
    auto multiply = [](int x, int y) { return x * y; };
    cout << "   5 * 3 = " << multiply(5, 3) << endl;
    
    // 2. Auto type deduction
    cout << "\n2. Auto type deduction:" << endl;
    auto value1 = 42;          // deduces int
    auto value2 = 3.14;        // deduces double
    auto value3 = "hello";     // deduces const char*
    cout << "   auto value1 = 42; // type: int" << endl;
    cout << "   auto value2 = 3.14; // type: double" << endl;
    
    // 3. Range-based for loop
    cout << "\n3. Range-based for loop:" << endl;
    vector<int> numbers = {1, 2, 3, 4, 5};
    cout << "   ";
    for (int n : numbers) cout << n << " ";
    cout << endl;
    
    // 4. Smart pointers (memory management)
    cout << "\n4. Smart pointers:" << endl;
    cout << "   Automatically manage memory (no manual delete needed)" << endl;
    
    // 5. String manipulation
    cout << "\n5. String manipulation:" << endl;
    string str1 = "Hello";
    string str2 = "World";
    string combined = str1 + " " + str2;
    cout << "   " << combined << endl;
    cout << "   Length: " << combined.length() << endl;
    cout << "   Uppercase: ";
    for (char c : combined) cout << (char)toupper(c);
    cout << endl;
    
    // 6. Pair and tuple
    cout << "\n6. Pair (store two values):" << endl;
    pair<string, int> person = {"Alice", 30};
    cout << "   Name: " << person.first << ", Age: " << person.second << endl;
    
    // 7. Exception handling
    cout << "\n7. Exception handling:" << endl;
    try {
        int x = 10, y = 0;
        if (y == 0) throw runtime_error("Division by zero");
    } catch (const runtime_error& e) {
        cout << "   Caught: " << e.what() << endl;
    }
}

// ============================================================================
// MAIN FUNCTION
// ============================================================================

int main() {
    cout << "\n" << string(60, '=') << endl;
    cout << "C++ PLAYGROUND: VARIABLES, CONDITIONS, LOOPS & OOP" << endl;
    cout << string(60, '=') << endl;
    
    section_variables();
    section_conditions();
    section_looping();
    section_aggregations();
    section_oop();
    section_cool_features();
    
    cout << "\n" << string(60, '=') << endl;
    cout << "END OF C++ PLAYGROUND" << endl;
    cout << string(60, '=') << "\n" << endl;
    
    return 0;
}
