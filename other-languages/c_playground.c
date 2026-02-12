// ============================================================================
// C Playground: Variables, Conditions, Aggregations, Looping & Struct OOP
// Note: C doesn't have native OOP, but we simulate it with structs and functions
// Compile: gcc c_playground.c -o c_playground -lm
// ============================================================================

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// ============================================================================
// SECTION 1: VARIABLE DECLARATIONS & DATA TYPES
// ============================================================================

void section_variables() {
    printf("\n");
    printf("============================================================\n");
    printf("SECTION 1: VARIABLE DECLARATIONS & DATA TYPES\n");
    printf("============================================================\n\n");
    
    // Integer types
    int age = 25;              // Standard integer (typically 4 bytes)
    short small_num = 100;     // Smaller integer (2 bytes)
    long large_num = 1000000;  // Larger integer (4 or 8 bytes)
    unsigned int count = 50;   // Only positive values
    printf("Integers:\n");
    printf("  age (int): %d\n", age);
    printf("  small_num (short): %d\n", small_num);
    printf("  large_num (long): %ld\n", large_num);
    printf("  count (unsigned int): %u\n", count);
    
    // Floating point types
    float height = 5.9f;           // Single precision
    double pi = 3.14159265359;     // Double precision
    printf("\nFloating point:\n");
    printf("  height (float): %.1f\n", height);
    printf("  pi (double): %.14f\n", pi);
    
    // Character type
    char letter = 'A';
    char digit = '5';
    printf("\nCharacter:\n");
    printf("  letter (char): %c\n", letter);
    printf("  digit (char): %c\n", digit);
    
    // String type (character arrays)
    char name[50] = "John Doe";
    char message[] = "Hello World";  // Compiler determines size
    printf("\nString (char array):\n");
    printf("  name (char[50]): %s\n", name);
    printf("  message (char[]): %s\n", message);
    
    // Arrays (fixed size)
    int numbers[5] = {1, 2, 3, 4, 5};
    printf("\nArray (fixed size):\n");
    printf("  int numbers[5]: ");
    for (int i = 0; i < 5; i++) printf("%d ", numbers[i]);
    printf("\n");
    
    // Dynamic arrays (allocated at runtime)
    int size = 5;
    int* dynamic_array = (int*)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        dynamic_array[i] = (i + 1) * 10;
    }
    printf("\nDynamic array:\n");
    printf("  malloc allocated: ");
    for (int i = 0; i < size; i++) printf("%d ", dynamic_array[i]);
    printf("\n");
    free(dynamic_array);  // Always free allocated memory
    
    // Constants
    const int MAX_USERS = 100;
    const double PI_CONST = 3.14159;
    printf("\nConstants:\n");
    printf("  const int MAX_USERS: %d\n", MAX_USERS);
    printf("  const double PI_CONST: %.5f\n", PI_CONST);
    
    // Pointers
    int value = 42;
    int* ptr = &value;  // Pointer to value
    printf("\nPointers:\n");
    printf("  value: %d\n", value);
    printf("  ptr points to: %d\n", *ptr);  // Dereference pointer
    printf("  address of value: %p\n", (void*)ptr);
}

// ============================================================================
// SECTION 2: CONDITIONS & CONTROL FLOW
// ============================================================================

void section_conditions() {
    printf("\n");
    printf("============================================================\n");
    printf("SECTION 2: CONDITIONS & CONTROL FLOW\n");
    printf("============================================================\n\n");
    
    // Basic if-else-if
    int age = 25;
    if (age < 13) {
        printf("Child\n");
    } else if (age < 18) {
        printf("Teenager\n");
    } else if (age < 65) {
        printf("Adult\n");
    } else {
        printf("Senior\n");
    }
    
    // Comparison operators
    int x = 10, y = 20;
    printf("\nComparison operators:\n");
    printf("  %d == %d: %d\n", x, y, x == y);
    printf("  %d != %d: %d\n", x, y, x != y);
    printf("  %d < %d: %d\n", x, y, x < y);
    printf("  %d > %d: %d\n", x, y, x > y);
    printf("  %d <= %d: %d\n", x, y, x <= y);
    printf("  %d >= %d: %d\n", x, y, x >= y);
    
    // Logical operators
    printf("\nLogical operators:\n");
    printf("  age > 18 && age < 65: %d\n", (age > 18 && age < 65));
    printf("  age < 13 || age > 65: %d\n", (age < 13 || age > 65));
    printf("  !(age == 25): %d\n", !(age == 25));
    
    // Ternary operator
    char* status = (age >= 18) ? "Adult" : "Minor";
    printf("\nTernary operator:\n");
    printf("  status: %s\n", status);
    
    // Switch statement
    char grade = 'B';
    printf("\nSwitch statement:\n");
    switch (grade) {
        case 'A': printf("  Grade A: Excellent\n"); break;
        case 'B': printf("  Grade B: Good\n"); break;
        case 'C': printf("  Grade C: Average\n"); break;
        default: printf("  Grade: Unknown\n");
    }
}

// ============================================================================
// SECTION 3: LOOPING & ITERATION
// ============================================================================

void section_looping() {
    printf("\n");
    printf("============================================================\n");
    printf("SECTION 3: LOOPING & ITERATION\n");
    printf("============================================================\n\n");
    
    // For loop
    printf("For loop (0-4): ");
    for (int i = 0; i < 5; i++) {
        printf("%d ", i);
    }
    printf("\n");
    
    // For loop with step
    printf("For loop (0-10, step 2): ");
    for (int i = 0; i <= 10; i += 2) {
        printf("%d ", i);
    }
    printf("\n");
    
    // For loop over array
    int numbers[] = {10, 20, 30, 40, 50};
    printf("For loop over array: ");
    for (int i = 0; i < 5; i++) {
        printf("%d ", numbers[i]);
    }
    printf("\n");
    
    // While loop
    printf("While loop (countdown): ");
    int count = 3;
    while (count > 0) {
        printf("%d ", count);
        count--;
    }
    printf("Blast off!\n");
    
    // Do-while loop (runs at least once)
    printf("Do-while loop: ");
    int x = 1;
    do {
        printf("%d ", x);
        x++;
    } while (x <= 3);
    printf("\n");
    
    // Break statement
    printf("Break (stop at 5): ");
    for (int i = 0; i < 10; i++) {
        if (i == 5) break;
        printf("%d ", i);
    }
    printf("\n");
    
    // Continue statement
    printf("Continue (skip 3): ");
    for (int i = 0; i < 6; i++) {
        if (i == 3) continue;
        printf("%d ", i);
    }
    printf("\n");
    
    // Nested loops
    printf("Nested loops (3x3 multiplication table):\n");
    for (int i = 1; i <= 3; i++) {
        for (int j = 1; j <= 3; j++) {
            printf("%dx%d=%-2d ", i, j, i*j);
        }
        printf("\n");
    }
}

// ============================================================================
// SECTION 4: AGGREGATIONS & TRANSFORMATIONS
// ============================================================================

void section_aggregations() {
    printf("\n");
    printf("============================================================\n");
    printf("SECTION 4: AGGREGATIONS & TRANSFORMATIONS\n");
    printf("============================================================\n\n");
    
    int numbers[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int size = 10;
    
    // Sum aggregation
    int total = 0;
    for (int i = 0; i < size; i++) {
        total += numbers[i];
    }
    printf("Sum: %d\n", total);
    
    // Count (size)
    printf("Count: %d\n", size);
    
    // Average
    double average = (double)total / size;
    printf("Average: %.2f\n", average);
    
    // Min and Max
    int min_val = numbers[0];
    int max_val = numbers[0];
    for (int i = 1; i < size; i++) {
        if (numbers[i] < min_val) min_val = numbers[i];
        if (numbers[i] > max_val) max_val = numbers[i];
    }
    printf("Min: %d, Max: %d\n", min_val, max_val);
    
    // Count even numbers
    int even_count = 0;
    for (int i = 0; i < size; i++) {
        if (numbers[i] % 2 == 0) even_count++;
    }
    printf("\nEven count: %d\n");
    printf("Even numbers: ");
    for (int i = 0; i < size; i++) {
        if (numbers[i] % 2 == 0) printf("%d ", numbers[i]);
    }
    printf("\n");
    
    // Squares of numbers
    printf("Squares: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", numbers[i] * numbers[i]);
    }
    printf("\n");
    
    // Simple bubble sort (ascending)
    int unsorted[] = {3, 1, 4, 1, 5, 9, 2, 6, 5};
    int sort_size = 9;
    
    printf("\nSorting:\n");
    printf("  Original: ");
    for (int i = 0; i < sort_size; i++) printf("%d ", unsorted[i]);
    printf("\n");
    
    // Bubble sort
    for (int i = 0; i < sort_size; i++) {
        for (int j = 0; j < sort_size - 1 - i; j++) {
            if (unsorted[j] > unsorted[j + 1]) {
                int temp = unsorted[j];
                unsorted[j] = unsorted[j + 1];
                unsorted[j + 1] = temp;
            }
        }
    }
    
    printf("  Sorted: ");
    for (int i = 0; i < sort_size; i++) printf("%d ", unsorted[i]);
    printf("\n");
}

// ============================================================================
// SECTION 5: STRUCT-BASED OOP (SIMULATING CLASSES)
// ============================================================================

// Simple struct (class-like)
typedef struct {
    char name[50];
    char species[50];
    int age;
} Animal;

// Function to create and initialize an Animal (constructor-like)
Animal animal_create(const char* name, const char* species) {
    Animal animal;
    strcpy(animal.name, name);
    strcpy(animal.species, species);
    animal.age = 0;
    return animal;
}

// Method-like function
void animal_describe(const Animal* animal) {
    printf("%s is a %s\n", animal->name, animal->species);
}

// Another method
void animal_age_one_year(Animal* animal) {
    animal->age++;
    printf("%s is now %d years old\n", animal->name, animal->age);
}

// More complex struct with function pointers (simulating polymorphism)
typedef struct {
    char name[50];
    void (*make_sound)(void);
} Bird;

void duck_sound(void) {
    printf("Quack!\n");
}

void owl_sound(void) {
    printf("Hoo hoo!\n");
}

void bird_make_sound(const Bird* bird) {
    printf("%s says: ", bird->name);
    bird->make_sound();
}

void section_oop() {
    printf("\n");
    printf("============================================================\n");
    printf("SECTION 5: STRUCT-BASED OOP (SIMULATING CLASSES)\n");
    printf("============================================================\n\n");
    
    // Create and use Animal structs
    printf("Creating Animal structs:\n");
    Animal dog = animal_create("Buddy", "Dog");
    Animal cat = animal_create("Whiskers", "Cat");
    
    animal_describe(&dog);
    animal_describe(&cat);
    animal_age_one_year(&dog);
    animal_age_one_year(&dog);
    
    // Function pointers for polymorphism
    printf("\nPolymorphism with function pointers:\n");
    Bird duck = {"Donald", duck_sound};
    Bird owl = {"Oliver", owl_sound};
    
    bird_make_sound(&duck);
    bird_make_sound(&owl);
}

// ============================================================================
// SECTION 6: COOL FEATURES
// ============================================================================

void section_cool_features() {
    printf("\n");
    printf("============================================================\n");
    printf("SECTION 6: COOL FEATURES\n");
    printf("============================================================\n\n");
    
    // 1. Macros (preprocessor directives)
    printf("1. Macros:\n");
    #define MAX(a, b) ((a) > (b) ? (a) : (b))
    printf("   MAX(10, 5) = %d\n", MAX(10, 5));
    
    // 2. Typedef (create type aliases)
    printf("\n2. Typedef:\n");
    typedef unsigned int uint;
    uint value = 42;
    printf("   uint value = %u\n", value);
    
    // 3. Bit operations
    printf("\n3. Bit operations:\n");
    int a = 5;   // 0101
    int b = 3;   // 0011
    printf("   5 & 3 (AND) = %d\n", a & b);     // 0001 = 1
    printf("   5 | 3 (OR) = %d\n", a | b);      // 0111 = 7
    printf("   5 ^ 3 (XOR) = %d\n", a ^ b);     // 0110 = 6
    printf("   ~5 (NOT) = %d\n", ~a);           // 1010
    printf("   5 << 1 (Left shift) = %d\n", a << 1);   // 10
    printf("   5 >> 1 (Right shift) = %d\n", a >> 1);  // 2
    
    // 4. Pointers and pointer arithmetic
    printf("\n4. Pointers and arithmetic:\n");
    int arr[] = {10, 20, 30, 40, 50};
    int* ptr = arr;
    printf("   arr[0] = %d, *ptr = %d\n", arr[0], *ptr);
    printf("   arr[2] = %d, *(ptr+2) = %d\n", arr[2], *(ptr + 2));
    
    // 5. String functions
    printf("\n5. String functions:\n");
    char str1[20] = "Hello";
    char str2[20] = "World";
    char combined[40];
    sprintf(combined, "%s %s", str1, str2);
    printf("   Combined: %s\n", combined);
    printf("   Length: %lu\n", strlen(str1));
    
    // 6. Math functions
    printf("\n6. Math functions:\n");
    printf("   sqrt(16) = %.2f\n", sqrt(16.0));
    printf("   pow(2, 3) = %.2f\n", pow(2.0, 3.0));
    printf("   abs(-5) = %d\n", abs(-5));
    printf("   ceil(4.3) = %.2f\n", ceil(4.3));
    printf("   floor(4.7) = %.2f\n", floor(4.7));
    
    // 7. Enum
    printf("\n7. Enumeration:\n");
    enum Color { RED = 0, GREEN = 1, BLUE = 2 };
    enum Color favorite = GREEN;
    printf("   Favorite color code: %d\n", favorite);
    
    // 8. Union (shared memory)
    printf("\n8. Union (shared memory):\n");
    typedef union {
        int integer;
        float floating;
        char character;
    } Data;
    Data data;
    data.integer = 65;
    printf("   As integer: %d, As character: %c\n", data.integer, data.character);
}

// ============================================================================
// MAIN FUNCTION
// ============================================================================

int main() {
    printf("\n");
    printf("============================================================\n");
    printf("C PLAYGROUND: VARIABLES, CONDITIONS, LOOPS & OOP PATTERNS\n");
    printf("============================================================\n");
    
    section_variables();
    section_conditions();
    section_looping();
    section_aggregations();
    section_oop();
    section_cool_features();
    
    printf("\n");
    printf("============================================================\n");
    printf("END OF C PLAYGROUND\n");
    printf("============================================================\n\n");
    
    return 0;
}
