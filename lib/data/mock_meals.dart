import 'package:bitewise/models/meal_model.dart';

final List<Map<String, dynamic>> mockMeals = [
  {
    'name': 'Mediterranean Quinoa Bowl',
    'description':
        'A healthy and flavorful bowl packed with Mediterranean ingredients, perfect for lunch or dinner.',
    'imageUrl':
        'https://example.com/mediterranean-quinoa.jpg', // Replace with actual image URL
    'ingredients': [
      '1 cup quinoa',
      '1 cucumber, diced',
      '1 cup cherry tomatoes, halved',
      '1/2 red onion, thinly sliced',
      '1/2 cup feta cheese, crumbled',
      '1/4 cup Kalamata olives',
      '2 tbsp olive oil',
      '1 tbsp lemon juice',
      '1 tsp dried oregano',
      'Salt and pepper to taste'
    ],
    'instructions': [
      'Cook quinoa according to package instructions',
      'Combine all vegetables in a large bowl',
      'Add cooked quinoa and mix well',
      'Top with feta cheese and olives',
      'Drizzle with olive oil and lemon juice',
      'Sprinkle with oregano, salt, and pepper'
    ],
    'calories': 450.0,
    'protein': 15.0,
    'carbs': 55.0,
    'fat': 20.0,
    'mealTypes': [MealType.lunch, MealType.dinner],
    'categories': [MealCategory.mediterranean, MealCategory.vegetarian],
    'allergens': ['dairy'],
    'isUserCreated': false,
    'isPublic': true,
    'rating': 4.5,
    'reviewCount': 120,
  },
  {
    'name': 'Vegan Buddha Bowl',
    'description':
        'A nourishing bowl filled with roasted vegetables, grains, and a tahini dressing.',
    'imageUrl': 'https://example.com/buddha-bowl.jpg',
    'ingredients': [
      '1 cup brown rice',
      '1 sweet potato, cubed',
      '1 cup chickpeas',
      '2 cups kale',
      '1 avocado',
      '1/4 cup tahini',
      '2 tbsp lemon juice',
      '1 tbsp maple syrup',
      '1 clove garlic, minced',
      'Salt and pepper to taste'
    ],
    'instructions': [
      'Cook brown rice according to package instructions',
      'Roast sweet potato cubes until tender',
      'Massage kale with olive oil and salt',
      'Prepare tahini dressing by mixing all ingredients',
      'Assemble bowl with rice, vegetables, and dressing'
    ],
    'calories': 550.0,
    'protein': 18.0,
    'carbs': 65.0,
    'fat': 25.0,
    'mealTypes': [MealType.lunch, MealType.dinner],
    'categories': [MealCategory.vegan, MealCategory.highProtein],
    'allergens': ['nuts'],
    'isUserCreated': false,
    'isPublic': true,
    'rating': 4.7,
    'reviewCount': 85,
  },
  {
    'name': 'Protein-Packed Breakfast Burrito',
    'description':
        'A hearty breakfast burrito filled with eggs, black beans, and vegetables.',
    'imageUrl': 'https://example.com/breakfast-burrito.jpg',
    'ingredients': [
      '4 large eggs',
      '1/2 cup black beans',
      '1/4 cup diced bell peppers',
      '1/4 cup diced onions',
      '2 tbsp olive oil',
      '2 large whole wheat tortillas',
      '1/4 cup shredded cheese',
      '1 avocado',
      'Hot sauce to taste',
      'Salt and pepper to taste'
    ],
    'instructions': [
      'Scramble eggs with salt and pepper',
      'Sauté vegetables until tender',
      'Warm tortillas',
      'Layer ingredients in tortillas',
      'Roll up and serve with hot sauce'
    ],
    'calories': 650.0,
    'protein': 35.0,
    'carbs': 45.0,
    'fat': 30.0,
    'mealTypes': [MealType.breakfast],
    'categories': [MealCategory.highProtein, MealCategory.american],
    'allergens': ['eggs', 'dairy', 'gluten'],
    'isUserCreated': false,
    'isPublic': true,
    'rating': 4.8,
    'reviewCount': 150,
  },
  {
    'name': 'Gluten-Free Poke Bowl',
    'description':
        'A fresh and healthy poke bowl with sushi-grade tuna and vegetables.',
    'imageUrl': 'https://example.com/poke-bowl.jpg',
    'ingredients': [
      '8 oz sushi-grade tuna',
      '1 cup sushi rice',
      '1/2 cucumber, sliced',
      '1/2 avocado',
      '1/4 cup edamame',
      '1/4 cup seaweed salad',
      '2 tbsp soy sauce',
      '1 tbsp sesame oil',
      '1 tsp ginger, minced',
      'Sesame seeds for garnish'
    ],
    'instructions': [
      'Cook sushi rice according to package instructions',
      'Cube tuna into bite-sized pieces',
      'Prepare vegetables and toppings',
      'Mix soy sauce, sesame oil, and ginger',
      'Assemble bowl and drizzle with sauce'
    ],
    'calories': 580.0,
    'protein': 40.0,
    'carbs': 50.0,
    'fat': 22.0,
    'mealTypes': [MealType.lunch, MealType.dinner],
    'categories': [MealCategory.glutenFree, MealCategory.asian],
    'allergens': ['fish', 'soy'],
    'isUserCreated': false,
    'isPublic': true,
    'rating': 4.6,
    'reviewCount': 95,
  },
  {
    'name': 'Keto Chicken Caesar Salad',
    'description':
        'A low-carb version of the classic Caesar salad with grilled chicken.',
    'imageUrl': 'https://example.com/caesar-salad.jpg',
    'ingredients': [
      '2 chicken breasts',
      '1 head romaine lettuce',
      '1/4 cup parmesan cheese',
      '2 tbsp olive oil',
      '1 tbsp Dijon mustard',
      '1 clove garlic, minced',
      '1 tbsp lemon juice',
      '2 anchovy fillets',
      'Salt and pepper to taste'
    ],
    'instructions': [
      'Grill chicken breasts until cooked through',
      'Chop lettuce into bite-sized pieces',
      'Prepare Caesar dressing',
      'Slice chicken and combine with lettuce',
      'Top with parmesan and dressing'
    ],
    'calories': 420.0,
    'protein': 45.0,
    'carbs': 5.0,
    'fat': 25.0,
    'mealTypes': [MealType.lunch, MealType.dinner],
    'categories': [MealCategory.keto, MealCategory.lowCarb],
    'allergens': ['dairy', 'fish'],
    'isUserCreated': false,
    'isPublic': true,
    'rating': 4.4,
    'reviewCount': 75,
  }
];
