# Tutorial on using the Open Food Facts API

[cite\_start]Welcome to this tutorial on basic usage of Open Food Facts API[cite: 76].

[cite\_start]First, be sure to see the Introduction to the API[cite: 77].

-----

## Scan A Product To Get Nutri-score

[cite\_start]This basic tutorial shows how you can get the **Nutri-Score** of a product, for instance, to display it in a mobile app after scanning the product barcode[cite: 79]. [cite\_start]We will use **Nutella Ferrero** as the product example for this tutorial[cite: 80].

### Authentication

[cite\_start]Usually, no authentication is required to query the Nutri-Score for a product[cite: 83].

[cite\_start]However, there is a **basic auth** to avoid content indexation in the **staging environment**, which is used throughout this tutorial[cite: 84]. [cite\_start]For more details, visit the Open Food Facts API Environment[cite: 85].

### Describing the Get Request

[cite\_start]Make a **GET** request to the **Get A Product By Barcode** endpoint[cite: 87].

```
https://world.openfoodfacts.net/api/v2/product/{barcode}
```

[cite\_start]The `{barcode}` is the barcode number of the product you are trying to get[cite: 89]. [cite\_start]The barcode for Nutella Ferrero is `3017624010701`[cite: 90].

The request path to get product data for Nutella Ferrero will look like this:

```
https://world.openfoodfacts.net/api/v2/product/3017624010701
```

[cite\_start]The response returns every data about Nutella Ferrero on the database[cite: 92]. [cite\_start]To get the Nutri-Score, you can limit the response by specifying the fields: `nutrition_grades` and `product_name`[cite: 93].

### Query Parameters

[cite\_start]To limit the response of the Get A Product By Barcode endpoint, use query parameters to specify the product fields to be returned[cite: 96].

[cite\_start]In this example, you need one query parameter called `fields` with the value `product_name,nutrition_grades`[cite: 97].

The request path will now look like this:

```
https://world.openfoodfacts.net/api/v2/product/3017624010701?fields=product_name,nutrition_grades
```

### Nutri-Score Response

[cite\_start]The returned response contains an object with `code`, `product`, `status_verbose`, and `status`[cite: 101]. [cite\_start]The `product` object contains the specified fields: the `product_name` and the `nutrition_grades`[cite: 102]. [cite\_start]The `status` also states if the product was found or not[cite: 103].

```json
{
"code": "3017624010701",
"product": {
"nutrition_grades": "e",
"product_name": "Nutella"
},
"status": 1,
"status_verbose": "product found"
}
```

### Nutri-Score Computation

[cite\_start]If you would like to be able to show how the score is computed, add extra fields like `nutriscore_data` and `nutriments`[cite: 114].

The request path to get the Nutri-Score computation for Nutella-Ferrero will be:

```
https://world.openfoodfacts.net/api/v2/product/3017624010701?fields=product_name,nutriscore_data,nutriments,nutrition_grades
```

[cite\_start]The `product` object in the response now contains the extra fields to show how the Nutri-Score was computed[cite: 117].

```json
{
"code": "3017624010701",
"product": {
"nutriments": {
"carbohydrates": 57.5,
"carbohydrates_100g": 57.5,
"carbohydrates_unit": "g",
"carbohydrates_value": 57.5,
"energy": 2255,
"energy-kcal": 539,
"energy-kcal_100g": 539,
"energy-kcal_unit": "kcal",
"sugars": 56.3,
"sugars_100g": 56.3,
"sugars_unit": "g",
"sugars_value": 56.3
},
"nutriscore_data": {
"energy": 2255,
"energy_points": 6,
"energy_value": 2255,
"sugars_points": 10,
"sugars_value": 56.3
},
"nutrition_grades": "e",
"product_name": "Nutella"
},
"status": 1,
"status_verbose": "product found"
}
```

[cite\_start]For more details, see the reference documentation for **Get A Product By Barcode**[cite: 152].

-----

## Completing products to get the Nutri-Score

### Products without a Nutri-Score

[cite\_start]When certain fields are missing in a Nutri-Score computation response, it signifies that the product does not have a Nutri-Score computation due to some missing nutrition data[cite: 156].

[cite\_start]For example, for a product like 100% Real Orange Juice, if product nutrition data is missing some fields, you can volunteer and contribute by getting the missing tags and writing to the OFF API to add them[cite: 157].

[cite\_start]To know the missing tags, check the `misc-tags` field from the product response[cite: 159].

```
https://world.openfoodfacts.net/api/v2/product/0180411000803/100-real-orange-juice?fields=misc_tags
```

[cite\_start]The response shows the missing fields and category needed to compute the Nutri-Score[cite: 161]:

```json
{
"code": "0180411000803",
"product": {
"misc_tags": [
"en:nutriscore-not-computed",
"en:nutriscore-missing-category",
"en:nutrition-not-enough-data-to-compute-nutrition-score",
"en:nutriscore-missing-nutrition-data",
"en:nutriscore-missing-nutrition-data-sodium",
"en:ecoscore-extended-data-not-computed",
"en:ecoscore-not-computed",
"en:main-countries-new-product"
]
},
"status": 1,
"status_verbose": "product found"
}
```

[cite\_start]The sample response above for 100% Real Orange Juice's `misc_tags` shows that the Nutri-Score is missing a category (`en:nutriscore-missing-category`) and sodium/salt data (`en:nutriscore-missing-nutrition-data-sodium`)[cite: 179]. [cite\_start]Now you can write to the OFF API to provide this data (if you have it) so that the Nutri-Score can be computed[cite: 180].

### Write data to make Nutri-Score computation possible

[cite\_start]The **WRITE** operations in the OFF API require authentication[cite: 182]. [cite\_start]Therefore, you need a valid `user_id` (which is your username, not your email address) [cite: 182, 206] [cite\_start]and `password` to write the missing nutriment data[cite: 182]. [cite\_start]You must **sign up on the Open Food Facts App** to get your `user_id` and `password` if you don't have one[cite: 183].

[cite\_start]To write data to a product, make a **POST** request to the **Add or Edit A Product** endpoint[cite: 184]:

```
https://world.openfoodfacts.net/cgi/product_jqm2.pl
```

[cite\_start]Add your valid `user_id` and `password` as body parameters to your request for authentication[cite: 186]. [cite\_start]The `code` (barcode of the product), `user_id`, and `password` are **required** when adding or editing a product[cite: 187]. [cite\_start]Then, include other product data to be added in the request body[cite: 188].

To write sodium and category to 100% Real Orange Juice, the request body should contain these fields:

| Key | Value | Description |
| :--- | :--- | :--- |
| `user_id` | `***` | A valid user\_id |
| `password` | `***` | A valid password |
| `code` | `0180411000803` | The barcode of the product to be added/edited |
| `nutriment_sodium` | `0.015` | Amount of sodium |
| `nutriment_sodium_unit` | `g` | Unit of sodium relative to the amount |
| `categories` | `Orange Juice` | Category of the Product |

Using `curl`:

```bash
curl -XPOST -x POST https://world.openfoodfacts.net/cgi/product_jqm2.pl \
-F user_id=your_user_id -F password=your_password \
-F code=0180411000803 -F nutriment_sodium=0.015 -F nutriment_sodium_unit=g -F categories="Orange Juice"
```

[cite\_start]If the request is successful, it returns a response that indicates that the fields have been saved[cite: 201]:

```json
{
"status_verbose": "fields saved",
"status": 1
}
```

### Read newly computed Nutri-Score

To check if the Nutri-Score for 100% Real Orange Juice has been computed after providing the missing data, make a **GET** request to:

```
https://world.openfoodfacts.net/api/v2/product/0180411000803?fields=product_name,nutriscore_data,nutriments,nutrition_grades
```

[cite\_start]The response now contains the Nutri-Score computation[cite: 209]:

```json
{
"code": "0180411000803",
"product": {
"nutriments": {
"carbohydrates": 11.864406779661,
// ... other nutriments ...
"sugars_unit": "g",
"sugars_value": 11.864406779661
},
"nutriscore_data": {
"energy": 195,
"energy_points": 7,
"energy_value": 195,
// ... other nutriscore data ...
"sugars_value": 11.86
},
"nutrition_grades": "c",
"product_name": "100% Real Orange Juice"
},
"status": 1,
"status_verbose": "product found"
}
```

[cite\_start]For more details, see the reference documentation for **Add or Edit A Product**[cite: 236]. [cite\_start]You can also check the reference cheatsheet to know how to add/edit other types of product data[cite: 237].

-----

## Search for a Product by Nutri-score

[cite\_start]Using the Open Food Facts API, you can filter products based on different criteria[cite: 240]. [cite\_start]To search for products in the **Orange Juice** category with a `nutrition_grade` of **c**, query the **Search for Products** endpoint[cite: 241].

> [cite\_start]**Note:** The v2 search API is described here, but only the v1 search API supports full text search[cite: 242].

### Describing the Search Request

[cite\_start]Make a **GET** request to the Search for Products endpoint[cite: 244]:

```
https://world.openfoodfacts.org/api/v2/search
```

[cite\_start]Add the search criteria as query parameters to filter the products[cite: 246]. [cite\_start]For Orange Juice with a nutrition\_grade of c, add the query parameter `categories_tags_en` to filter for Orange Juice, and `nutrition_grades_tags` to filter for 'c'[cite: 247].

[cite\_start]The response will return all the products in the database matching these criteria[cite: 248].

```
https://world.openfoodfacts.net/api/v2/search?categories_tags_en=Orange Juice&nutrition_grades_tags=c
```

[cite\_start]To limit the response, add `fields` to the query parameters to specify the fields to be returned in each product object[cite: 250]. [cite\_start]For this tutorial, we limit the response to `code`, `nutrition_grades`, and `categories_tags_en`[cite: 251, 252].

```
https://world.openfoodfacts.net/api/v2/search?categories_tags_en=Orange Juice&nutrition_grades_tags=c&fields=code,nutrition_grades,categories_tags_en
```

[cite\_start]The response returns all matching products and the `count` (total number) of products that match the search criteria[cite: 253, 254].

```json
{
"count": 1629,
"page": 1,
"page_count": 24,
"page_size": 24,
"products": [
{
"categories_tags_en": [
"Plant-based foods and beverages",
"Beverages",
// ...
"Orange juices",
"Concentrated orange juices"
],
"code": "3123340008288",
"nutrition_grades": "c"
},
// ...
{
"categories_tags_en": [
"Plant-based foods and beverages",
"Beverages",
// ...
"Orange juices",
"Squeezed juices",
"Squeezed orange juices"
],
"code": "3608580844136",
"nutrition_grades": "c"
}
],
"skip": 0
}
```

### Sorting Search Response

[cite\_start]You can also sort the search response by different fields, for example, by when the product was modified last or by `product_name`[cite: 299].

[cite\_start]To sort the products (Orange Juice, nutrition\_grade "c") by when they were last modified, add the `sort_by` query parameter with the value `last_modified_t` to the request[cite: 301, 302].

```
https://world.openfoodfacts.net/api/v2/search?nutrition_grades_tags=c&fields=code,nutrition_grades,categories_tags_en&categories_tags_en=Orange Juice&sort_by=last_modified_t
```

[cite\_start]The date that each product was last modified is now used to order the product response[cite: 303].

```json
{
"count": 1629,
"page": 1,
"page_count": 24,
"page_size": 24,
"products": [
{
"categories_tags_en": [
"Plant-based foods and beverages",
// ...
"Fruit juices",
"Orange juices"
],
"code": "3800014268048",
"nutrition_grades": "c"
},
// ...
{
"categories_tags_en": [
"Plant-based foods and beverages",
// ...
"Orange juices",
"Squeezed juices",
"Squeezed orange juices"
],
"code": "4056489641018",
"nutrition_grades": "c"
}
],
"skip": 0
}
```