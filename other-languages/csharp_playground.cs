// ============================================================================
// C# Playground: Variables, Conditions, Aggregations, Looping & OOP
// Comprehensive guide with examples and comments
// Compile: csc csharp_playground.cs
// Run: ./csharp_playground.exe (Windows) or mono csharp_playground.exe (Linux)
// ============================================================================

using System;
using System.Collections.Generic;
using System.Linq;

namespace CSharpPlayground {
    // ============================================================================
    // SECTION 1: VARIABLE DECLARATIONS & DATA TYPES
    // ============================================================================
    
    class VariablesDemo {
        public static void Run() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("SECTION 1: VARIABLE DECLARATIONS & DATA TYPES");
            Console.WriteLine(new string('=', 60) + "\n");
            
            // Integer types
            byte small_byte = 255;         // 0-255 (1 byte)
            short small_int = 32000;       // -32,768 to 32,767 (2 bytes)
            int age = 25;                  // Standard integer (4 bytes)
            long large_number = 1000000;   // Large numbers (8 bytes)
            uint unsigned_int = 50;        // Only positive values (4 bytes)
            
            Console.WriteLine("Integer types:");
            Console.WriteLine($"  small_byte (byte): {small_byte}");
            Console.WriteLine($"  small_int (short): {small_int}");
            Console.WriteLine($"  age (int): {age}");
            Console.WriteLine($"  large_number (long): {large_number}");
            Console.WriteLine($"  unsigned_int (uint): {unsigned_int}");
            
            // Floating point types
            float height = 5.9f;           // Single precision (4 bytes)
            double pi = 3.14159265359;     // Double precision (8 bytes)
            decimal price = 19.99m;        // High precision for money (16 bytes)
            
            Console.WriteLine("\nFloating point types:");
            Console.WriteLine($"  height (float): {height}");
            Console.WriteLine($"  pi (double): {pi}");
            Console.WriteLine($"  price (decimal): ${price}");
            
            // Character and Boolean
            char letter = 'A';
            bool is_developer = true;
            bool is_student = false;
            
            Console.WriteLine("\nCharacter and Boolean:");
            Console.WriteLine($"  letter (char): {letter}");
            Console.WriteLine($"  is_developer (bool): {is_developer}");
            Console.WriteLine($"  is_student (bool): {is_student}");
            
            // String type
            string name = "John Doe";
            string message = "Hello World";
            
            Console.WriteLine("\nString type:");
            Console.WriteLine($"  name (string): {name}");
            Console.WriteLine($"  message (string): {message}");
            
            // Arrays (fixed size)
            int[] numbers = {1, 2, 3, 4, 5};
            string[] fruits = {"apple", "banana", "cherry"};
            
            Console.WriteLine("\nArray (fixed size):");
            Console.Write("  int[] numbers: ");
            foreach (int num in numbers) Console.Write($"{num} ");
            Console.WriteLine();
            
            // Lists (dynamic arrays)
            List<int> dynamic_numbers = new List<int> {1, 2, 3, 4, 5};
            dynamic_numbers.Add(6);
            dynamic_numbers.Add(7);
            
            Console.WriteLine("\nList (dynamic array):");
            Console.Write("  List<int>: ");
            foreach (int num in dynamic_numbers) Console.Write($"{num} ");
            Console.WriteLine();
            
            // Dictionary (key-value pairs)
            Dictionary<string, int> ages = new Dictionary<string, int>
            {
                {"Alice", 30},
                {"Bob", 25},
                {"Charlie", 35}
            };
            
            Console.WriteLine("\nDictionary (key-value):");
            foreach (var kvp in ages) {
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
            }
            
            // Nullable types
            int? nullable_int = null;
            nullable_int = 42;
            
            Console.WriteLine("\nNullable type:");
            Console.WriteLine($"  int? nullable_int: {nullable_int}");
            
            // Type checking
            Console.WriteLine("\nType checking:");
            Console.WriteLine($"  typeof(age): {age.GetType()}");
            Console.WriteLine($"  typeof(height): {height.GetType()}");
            Console.WriteLine($"  typeof(name): {name.GetType()}");
        }
    }
    
    // ============================================================================
    // SECTION 2: CONDITIONS & CONTROL FLOW
    // ============================================================================
    
    class ConditionsDemo {
        public static void Run() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("SECTION 2: CONDITIONS & CONTROL FLOW");
            Console.WriteLine(new string('=', 60) + "\n");
            
            // Basic if-else-if
            int age = 25;
            if (age < 13) {
                Console.WriteLine("Child");
            } else if (age < 18) {
                Console.WriteLine("Teenager");
            } else if (age < 65) {
                Console.WriteLine("Adult");
            } else {
                Console.WriteLine("Senior");
            }
            
            // Comparison operators
            int x = 10, y = 20;
            Console.WriteLine("\nComparison operators:");
            Console.WriteLine($"  {x} == {y}: {x == y}");
            Console.WriteLine($"  {x} != {y}: {x != y}");
            Console.WriteLine($"  {x} < {y}: {x < y}");
            Console.WriteLine($"  {x} > {y}: {x > y}");
            Console.WriteLine($"  {x} <= {y}: {x <= y}");
            Console.WriteLine($"  {x} >= {y}: {x >= y}");
            
            // Logical operators
            Console.WriteLine("\nLogical operators:");
            Console.WriteLine($"  age > 18 && age < 65: {(age > 18 && age < 65)}");
            Console.WriteLine($"  age < 13 || age > 65: {(age < 13 || age > 65)}");
            Console.WriteLine($"  !(age == 25): {!(age == 25)}");
            
            // Ternary operator
            string status = (age >= 18) ? "Adult" : "Minor";
            Console.WriteLine($"\nTernary operator:");
            Console.WriteLine($"  status: {status}");
            
            // Switch statement
            char grade = 'B';
            Console.WriteLine($"\nSwitch statement:");
            switch (grade) {
                case 'A':
                    Console.WriteLine("  Grade A: Excellent");
                    break;
                case 'B':
                    Console.WriteLine("  Grade B: Good");
                    break;
                case 'C':
                    Console.WriteLine("  Grade C: Average");
                    break;
                default:
                    Console.WriteLine("  Grade: Unknown");
                    break;
            }
            
            // Switch expression (C# 8.0+)
            Console.WriteLine($"\nSwitch expression:");
            string description = grade switch {
                'A' => "Excellent",
                'B' => "Good",
                'C' => "Average",
                _ => "Unknown"
            };
            Console.WriteLine($"  {description}");
        }
    }
    
    // ============================================================================
    // SECTION 3: LOOPING & ITERATION
    // ============================================================================
    
    class LoopingDemo {
        public static void Run() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("SECTION 3: LOOPING & ITERATION");
            Console.WriteLine(new string('=', 60) + "\n");
            
            // For loop
            Console.Write("For loop (0-4): ");
            for (int i = 0; i < 5; i++) {
                Console.Write($"{i} ");
            }
            Console.WriteLine();
            
            // For loop with step
            Console.Write("For loop (0-10, step 2): ");
            for (int i = 0; i <= 10; i += 2) {
                Console.Write($"{i} ");
            }
            Console.WriteLine();
            
            // Foreach loop (range-based)
            int[] numbers = {1, 2, 3, 4, 5};
            Console.Write("Foreach loop: ");
            foreach (int num in numbers) {
                Console.Write($"{num} ");
            }
            Console.WriteLine();
            
            // Foreach with index
            string[] fruits = {"apple", "banana", "cherry"};
            Console.WriteLine("\nForeach with index:");
            for (int i = 0; i < fruits.Length; i++) {
                Console.WriteLine($"  [{i}] {fruits[i]}");
            }
            
            // While loop
            Console.Write("\nWhile loop (countdown): ");
            int count = 3;
            while (count > 0) {
                Console.Write($"{count} ");
                count--;
            }
            Console.WriteLine("Blast off!");
            
            // Do-while loop
            Console.Write("Do-while loop: ");
            int x = 1;
            do {
                Console.Write($"{x} ");
                x++;
            } while (x <= 3);
            Console.WriteLine();
            
            // Break statement
            Console.Write("Break (stop at 5): ");
            for (int i = 0; i < 10; i++) {
                if (i == 5) break;
                Console.Write($"{i} ");
            }
            Console.WriteLine();
            
            // Continue statement
            Console.Write("Continue (skip 3): ");
            for (int i = 0; i < 6; i++) {
                if (i == 3) continue;
                Console.Write($"{i} ");
            }
            Console.WriteLine();
            
            // Nested loops
            Console.WriteLine("\nNested loops (3x3 multiplication table):");
            for (int i = 1; i <= 3; i++) {
                for (int j = 1; j <= 3; j++) {
                    Console.Write($"{i}x{j}={i*j:D2}  ");
                }
                Console.WriteLine();
            }
        }
    }
    
    // ============================================================================
    // SECTION 4: AGGREGATIONS & TRANSFORMATIONS
    // ============================================================================
    
    class AggregationsDemo {
        public static void Run() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("SECTION 4: AGGREGATIONS & TRANSFORMATIONS");
            Console.WriteLine(new string('=', 60) + "\n");
            
            int[] numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
            
            // Sum aggregation
            int total = numbers.Sum();
            Console.WriteLine($"Sum: {total}");
            
            // Count
            int count = numbers.Length;
            Console.WriteLine($"Count: {count}");
            
            // Average
            double average = numbers.Average();
            Console.WriteLine($"Average: {average:F2}");
            
            // Min and Max
            Console.WriteLine($"Min: {numbers.Min()}, Max: {numbers.Max()}");
            
            // LINQ transformations (map)
            var squared = numbers.Select(x => x * x);
            Console.WriteLine("\nLINQ Select (squared):");
            Console.Write("  ");
            foreach (var num in squared) Console.Write($"{num} ");
            Console.WriteLine();
            
            // LINQ filter (where)
            var even_numbers = numbers.Where(x => x % 2 == 0);
            Console.WriteLine("LINQ Where (even numbers):");
            Console.Write("  ");
            foreach (var num in even_numbers) Console.Write($"{num} ");
            Console.WriteLine();
            
            // LINQ first/last
            Console.WriteLine("\nLINQ First/Last:");
            Console.WriteLine($"  First: {numbers.First()}");
            Console.WriteLine($"  Last: {numbers.Last()}");
            Console.WriteLine($"  First > 5: {numbers.First(x => x > 5)}");
            
            // LINQ count with condition
            Console.WriteLine($"\nLINQ Count (even): {numbers.Count(x => x % 2 == 0)}");
            
            // LINQ aggregate (reduce)
            int product = numbers.Take(5).Aggregate((a, b) => a * b);
            Console.WriteLine($"LINQ Aggregate (product 1-5): {product}");
            
            // Grouping
            Console.WriteLine("\nGrouping by odd/even:");
            var grouped = numbers.GroupBy(x => x % 2 == 0 ? "even" : "odd");
            foreach (var group in grouped) {
                Console.Write($"  {group.Key}: ");
                foreach (var item in group) Console.Write($"{item} ");
                Console.WriteLine();
            }
            
            // Sorting
            int[] unsorted = {3, 1, 4, 1, 5, 9, 2, 6, 5};
            Console.WriteLine("\nSorting:");
            Console.Write("  Original: ");
            foreach (var num in unsorted) Console.Write($"{num} ");
            Console.WriteLine();
            
            var ascending = unsorted.OrderBy(x => x);
            Console.Write("  Ascending: ");
            foreach (var num in ascending) Console.Write($"{num} ");
            Console.WriteLine();
            
            var descending = unsorted.OrderByDescending(x => x);
            Console.Write("  Descending: ");
            foreach (var num in descending) Console.Write($"{num} ");
            Console.WriteLine();
        }
    }
    
    // ============================================================================
    // SECTION 5: OBJECT-ORIENTED PROGRAMMING (OOP)
    // ============================================================================
    
    // Basic class
    public class Animal {
        // Properties
        public string Name { get; set; }
        public string Species { get; set; }
        public int Age { get; private set; }
        public static string Kingdom { get; } = "Animalia";
        
        // Constructor
        public Animal(string name, string species) {
            Name = name;
            Species = species;
            Age = 0;
        }
        
        // Methods
        public virtual string Describe() {
            return $"{Name} is a {Species} ({Kingdom})";
        }
        
        public void AgeOneYear() {
            Age++;
            Console.WriteLine($"{Name} is now {Age} years old");
        }
    }
    
    // Inheritance - dog is-a animal
    public class Dog : Animal {
        public string Breed { get; set; }
        
        public Dog(string name, string breed) : base(name, "Dog") {
            Breed = breed;
        }
        
        public override string Describe() {
            return $"{base.Describe()} (Breed: {Breed})";
        }
    }
    
    // Polymorphism - different animals make different sounds
    public class Bird : Animal {
        public Bird(string name) : base(name, "Bird") { }
        
        public virtual string MakeSound() {
            return "Generic sound";
        }
    }
    
    public class Duck : Bird {
        public Duck(string name) : base(name) { }
        
        public override string MakeSound() {
            return "Quack!";
        }
    }
    
    public class Owl : Bird {
        public Owl(string name) : base(name) { }
        
        public override string MakeSound() {
            return "Hoo hoo!";
        }
    }
    
    // Encapsulation - private data with public interface
    public class BankAccount {
        private double balance;
        public string Owner { get; private set; }
        
        public BankAccount(string owner, double initial) {
            Owner = owner;
            balance = initial;
        }
        
        public string Deposit(double amount) {
            if (amount > 0) {
                balance += amount;
                return $"Deposited ${amount}. Balance: ${balance}";
            }
            return "Invalid amount";
        }
        
        public string Withdraw(double amount) {
            if (amount > 0 && amount <= balance) {
                balance -= amount;
                return $"Withdrew ${amount}. Balance: ${balance}";
            }
            return "Insufficient funds";
        }
        
        public double GetBalance() {
            return balance;
        }
    }
    
    class OOPDemo {
        public static void Run() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("SECTION 5: OBJECT-ORIENTED PROGRAMMING (OOP)");
            Console.WriteLine(new string('=', 60) + "\n");
            
            // Basic class usage
            Console.WriteLine("Creating animal objects:");
            Dog dog = new Dog("Buddy", "Golden Retriever");
            Console.WriteLine($"  {dog.Describe()}");
            dog.AgeOneYear();
            
            // Polymorphism
            Console.WriteLine("\nPolymorphism:");
            Bird[] birds = {
                new Duck("Donald"),
                new Owl("Oliver"),
                new Bird("Generic")
            };
            
            foreach (var bird in birds) {
                Console.WriteLine($"  {bird.MakeSound()}");
            }
            
            // Encapsulation
            Console.WriteLine("\nEncapsulation:");
            BankAccount account = new BankAccount("John", 1000);
            Console.WriteLine($"  {account.Deposit(500)}");
            Console.WriteLine($"  {account.Withdraw(200)}");
            Console.WriteLine($"  Balance: ${account.GetBalance()}");
        }
    }
    
    // ============================================================================
    // SECTION 6: COOL FEATURES
    // ============================================================================
    
    class CoolFeaturesDemo {
        public static void Run() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("SECTION 6: COOL FEATURES");
            Console.WriteLine(new string('=', 60) + "\n");
            
            // 1. Lambda functions
            Console.WriteLine("1. Lambda functions:");
            Func<int, int, int> multiply = (x, y) => x * y;
            Console.WriteLine($"   multiply(5, 3) = {multiply(5, 3)}");
            
            // 2. LINQ
            Console.WriteLine("\n2. LINQ queries:");
            var numbers = Enumerable.Range(1, 10);
            var result = numbers.Where(x => x % 2 == 0).Select(x => x * x);
            Console.Write("   Even squares: ");
            foreach (var num in result) Console.Write($"{num} ");
            Console.WriteLine();
            
            // 3. String interpolation
            Console.WriteLine("\n3. String interpolation (f-strings):");
            string name = "Alice";
            int age = 30;
            double height = 5.9;
            Console.WriteLine($"   {name} is {age} years old, {height}m tall");
            
            // 4. Tuples
            Console.WriteLine("\n4. Tuples:");
            (string n, int a) = ("Bob", 25);
            Console.WriteLine($"   Name: {n}, Age: {a}");
            
            // 5. Null-coalescing operator
            Console.WriteLine("\n5. Null-coalescing operator:");
            string? nullable_string = null;
            string value = nullable_string ?? "default value";
            Console.WriteLine($"   Result: {value}");
            
            // 6. Pattern matching
            Console.WriteLine("\n6. Pattern matching:");
            object obj = 42;
            string pattern_result = obj switch {
                int i => $"Integer: {i}",
                string s => $"String: {s}",
                _ => "Unknown type"
            };
            Console.WriteLine($"   {pattern_result}");
            
            // 7. Anonymous types
            Console.WriteLine("\n7. Anonymous types:");
            var person = new { Name = "Charlie", Age = 35, City = "NYC" };
            Console.WriteLine($"   Name: {person.Name}, Age: {person.Age}, City: {person.City}");
            
            // 8. Extension methods
            Console.WriteLine("\n8. Extension methods:");
            string text = "hello";
            Console.WriteLine($"   '{text}' reversed: '{text.Reverse()}'");
            
            // 9. Exception handling
            Console.WriteLine("\n9. Exception handling:");
            try {
                int result = 10 / int.Parse("0");
            } catch (DivideByZeroException) {
                Console.WriteLine("   Caught: Division by zero");
            } catch (FormatException) {
                Console.WriteLine("   Caught: Invalid format");
            } catch (Exception e) {
                Console.WriteLine($"   Caught: {e.Message}");
            } finally {
                Console.WriteLine("   Finally block executed");
            }
            
            // 10. Action and Func delegates
            Console.WriteLine("\n10. Delegates (Action and Func):");
            Action<string> greet = msg => Console.WriteLine($"   {msg}");
            greet("Hello from Action!");
            
            Func<int, int> square = x => x * x;
            Console.WriteLine($"   square(7) = {square(7)}");
        }
    }
    
    // ============================================================================
    // MAIN PROGRAM
    // ============================================================================
    
    class Program {
        static void Main() {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("C# PLAYGROUND: VARIABLES, CONDITIONS, LOOPS & OOP");
            Console.WriteLine(new string('=', 60));
            
            VariablesDemo.Run();
            ConditionsDemo.Run();
            LoopingDemo.Run();
            AggregationsDemo.Run();
            OOPDemo.Run();
            CoolFeaturesDemo.Run();
            
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("END OF C# PLAYGROUND");
            Console.WriteLine(new string('=', 60) + "\n");
        }
    }
}
