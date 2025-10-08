# Ingredient related features for 3rd party apps

**THIS IS A DRAFT**

-----

## Ingredient related features for 3rd party apps

### Introduction

[cite\_start]If you cannot get the information on a specific product, you can get your user to send photos and data, which will then be processed by Open Food Facts AI and contributors to get the computed result you want to show them[cite: 1349]. [cite\_start]You can implement the complete flow so that they get the result immediately with some effort on their side[cite: 1350]. [cite\_start]This will ensure user satisfaction[cite: 1351].

[cite\_start]Most of the operations described below are implemented in the `openfoodfacts-dart` plugin, but as individual operations, not as a coherent pipeline[cite: 1352].

The complete flow is:

1.  [cite\_start]Upload photo [cite: 1353]
2.  [cite\_start]Get OCR of the photo [cite: 1354]
3.  [cite\_start]Ask the user to validate the ingredients [cite: 1355]
4.  [cite\_start]Save the ingredients [cite: 1356]
5.  [cite\_start]Request the analysis [cite: 1357]
6.  [cite\_start]Show the product with analysis to your user [cite: 1358, 1359]

[cite\_start]For a product with no ingredients (or a new product) and thus no analysis [cite: 1360, 1361][cite\_start], ask the user to take a photo of the ingredients[cite: 1362].

### Dart/Flutter package

| Action | Relevant Link/Class |
| :--- | :--- |
| Get the status of the product | [cite\_start][ImageHelper class](https://openfoodfacts.github.io/openfoodfacts-dart/utils_ImageHelper/ImageHelper-class.html) [cite: 1365] |
| Upload ingredient photo | [cite\_start][ImageField class](https://openfoodfacts.github.io/openfoodfacts-dart/model_ProductImage/ImageField-class.html) [cite: 1366, 1367] |
| Get OCR of the photo | [cite\_start][OcrIngredientsResult class](https://openfoodfacts.github.io/openfoodfacts-dart/model_OcrIngredientsResult/OcrIngredientsResult-class.html) [cite: 1369] |
| | [cite\_start][OcrField class](https://openfoodfacts.github.io/openfoodfacts-dart/utils_OcrField/OcrField-class.html) [cite: 1370] |
| | [cite\_start][OcrField Extension](https://openfoodfacts.github.io/openfoodfacts-dart/utils_OcrField/OcrFieldExtension.html) [cite: 1371] |
| Send the ingredients | [cite\_start]- [cite: 1372] |
| Refresh product | [cite\_start]- [cite: 1373] |

-----

## Incomplete products

  * [cite\_start]If the product status is **`category-to-be-completed`** **AND** **`ingredients-to-be-completed`**[cite: 1375, 1376, 1377]:
      * [cite\_start]Show the message: "Add ingredients and a category to see the level of food processing and potential additives"[cite: 1379].
  * [cite\_start]If the product status is **`category-to-be-completed`**[cite: 1380, 1381]:
      * [cite\_start]Show the message: "Add a category to see the level of food processing and potential additives"[cite: 1383].
  * [cite\_start]If the product status is **`ingredients-to-be-completed`**[cite: 1384, 1385]:
      * [cite\_start]Show the message: "Add ingredients to see the level of food processing and potential additives"[cite: 1387].

[cite\_start] [cite: 1387]

-----

## POST Photos - Uploading

[cite\_start]Photos are the source and proof of data[cite: 1391]. [cite\_start]Read this topic to learn how to make calls to upload them to the database[cite: 1391].

[cite\_start]When you upload an image to Open Food Facts, the image is stored as is[cite: 1392]. [cite\_start]The first photo uploaded is autoselected as the "front" photo[cite: 1393].

**Read the following before uploading photos:**

  * [cite\_start]**Image Quality:** Uploading quality photos of a product, its ingredients, and nutrition table is very important, as it allows the Open Food Facts OCR system to retrieve important data to analyze the product[cite: 1395]. [cite\_start]The minimal allowed size for photos is **640 x 160 px**[cite: 1396].
  * [cite\_start]**Upload Behavior:** If you upload more than one photo for the front, ingredients, or nutrition facts, only the first photo of each category will be displayed[cite: 1397]. (You might want to take additional images of labels, recycling instructions, and so on) [cite\_start][cite: 1398]. [cite\_start]All photos will be saved[cite: 1398].
  * [cite\_start]**Label Languages:** Multilingual products have several photos based on languages present on the packaging[cite: 1399]. [cite\_start]You can specify the language by adding a lang code suffix to the request[cite: 1400].

### POST Photo Requests

[cite\_start]The API request to upload photos is very straightforward[cite: 1402].

[cite\_start]`POST https://us.openfoodfacts.org/cgi/product_image_upload.pl` [cite: 1403]

### Image Upload

[cite\_start]Then, add the parameter `imagefield` to the call and specify from which perspective the photo was taken[cite: 1405].

[cite\_start]`POST https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&product_image_upload.pl/imgupload_front=cheeriosfrontphoto.jpg` [cite: 1406]

### Parameters

| Parameter | Description |
| :--- | :--- |
| `code` | [cite\_start]The barcode of the product[cite: 1408]. |
| `imagefield` | Can be either: `front` | `ingredients` | `nutrition` | [cite\_start]`packaging` + `_` and a **2-letter language code**[cite: 1409]. (e.g., `"front_en"` for the front of the product in English, `"ingredients_fr"` for the list of ingredients in French) [cite\_start][cite: 1410]. |
| `imgupload_front_fr` | [cite\_start]Your image file if `imagefield=front_fr`[cite: 1411]. [cite\_start]The parameter name should follow the pattern `imgupload_{imagefield}` (e.g., `imgupload_front`, `imgupload_front_fr`)[cite: 1415, 1411]. |

**Example Parameters:**

| Parameter | Value |
| :--- | :--- |
| `code` | [cite\_start]`0074570036004` [cite: 1414] |
| `imgupload_front` | [cite\_start]`cheeriosfrontphoto.jpg` [cite: 1416] |

**Example Request:**

````bash
curl --location --request POST 'https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&imgupload_front=cheeriosfrontphoto.jpg'
[cite_start]``` [cite: 1419]

---

## POST Photos - Selecting, Cropping, Rotating

[cite_start]Selecting, cropping, and rotating photos are **non-destructive actions**[cite: 1429]. [cite_start]The original version of the image uploaded to the system is kept as is[cite: 1429]. [cite_start]The subsequent changes made to the image are also stored as versions of the original image[cite: 1430]. [cite_start]These actions do not modify the image but provide metadata on how to use it (the data of the corners for selection and the data of the rotation)[cite: 1431]. [cite_start]That is, you send an image to the API, provide an ID, define the parameters (e.g., cropping and rotation), and the server generates a new version of the image that you can call[cite: 1432].

### Selecting and Cropping Photos

[cite_start]**Note:** Cropping is only relevant for editing **existing products**[cite: 1434]. [cite_start]You cannot crop an image the first time you upload it to the system[cite: 1435].

#### Parameters

[cite_start]To select and crop photos, you need to define[cite: 1437]:
* [cite_start]A **barcode** (`code`)[cite: 1438].
* [cite_start]An incremental **ID** (similar to a version)[cite: 1439].
* [cite_start]**Cropping parameters** (`x1`, `y1`, `x2`, `y2`)[cite: 1440]. [cite_start]These coordinates define a rectangle in the image and the area that should be kept (e.g., `0,0,200,200` px)[cite: 1440, 1441].

#### Example:

`POST https://world.openfoodfacts.org/cgi/product_image_crop.pl?code=3266110700910&id=nutrition_fr&imgid=1&x1=0&y1=0&x2=200&y2=200`

### Rotating Photos

#### Parameters

[cite_start]You can define optional additional operations[cite: 1442]:
* [cite_start]`angle`: Angle of the rotation (e.g., `90`)[cite: 1443].

#### Example:

[cite_start]`POST https://world.openfoodfacts.org/cgi/product_image_crop.pl?code=3266110700910&id=nutrition_fr&imgid=1&angle=90` [cite: 1445]

### Test server

[cite_start]The test server for this operation is[cite: 1446]:
[cite_start]`https://world.openfoodfacts.net/cgi/product_image_crop.org` [cite: 1447]

---

## POST Photos - Performing OCR

[cite_start]Open Food Facts uses optical character recognition (OCR) to retrieve nutritional data and other information from the product labels[cite: 1454].

### Process

1.  [cite_start]Capture the barcode of the product where you want to perform the OCR[cite: 1456].
2.  [cite_start]The Product Opener server software opens the image (`process_image=1`)[cite: 1457].
3.  [cite_start]Product Opener returns a JSON response[cite: 1458]. [cite_start]Processing is done using Tesseract or **Google Cloud Vision** (recommended)[cite: 1458].
4.  [cite_start]The result is often marred with errors with Tesseract, and less so with Google Cloud Vision[cite: 1459].

**Notes:**

* [cite_start]The OCR may contain errors[cite: 1460]. [cite_start]Encourage your users to correct the output using the ingredients WRITE API[cite: 1461].
* [cite_start]You can also use your own OCR, especially if you plan to send a high number of queries[cite: 1462].

### OCR with Google Cloud Vision

[cite_start]We recommend Google's Vision API to detect and extract text from the images[cite: 1464]. [cite_start]For more information, see: [https://cloud.google.com/vision/docs/ocr?hl=en](https://cloud.google.com/vision/docs/ocr?hl=en)[cite: 1465].

### Parameters

| Parameter | Description |
| :--- | :--- |
| `code` | [cite_start]The barcode of the product (`code=code`)[cite: 1468]. |
| `id` | [cite_start]The image field (`id=imagefield`)[cite: 1469]. |
| `process_image` | [cite_start]Must be set to `1` (`process_image=1`)[cite: 1470]. |
| `ocr_engine` | (Optional, use `ocr_engine=google` for Google Cloud Vision or `ocr_engine=tesseract` for Tesseract). |

**Example Request:**

`https://world.openfoodfacts.net/cgi/ingredients.pl?code=13333560&id=ingredients_en&process_image=1&ocr_engine=google`

[cite_start]**Test Server:** [cite: 1467]
[cite_start]`https://world.openfoodfacts.org/cgi/ingredients.pl` [cite: 1467]

---

## WRITE Scenario - Adding New products

[cite_start]Dave, an active Open Food Facts contributor, has described the process for adding new products and completing missing information via API calls to show other developers how easy it is to contribute[cite: 1472, 1473].

### Structure of the Call

#### Authentication and Header

[cite_start]If you have an app that makes `POST` calls and you do not want your users to authenticate in Open Food Facts, you can create a **global account**[cite: 1476].

Dave's global account credentials for his app are:
* [cite_start]`user_id`: `myappname` [cite: 1478]
* [cite_start]`password`: `123456` [cite: 1479]

#### Subdomain

[cite_start]Dave wants to define the subdomain as **`us`**[cite: 1481]. [cite_start]The subdomain automatically defines the country code (`cc`) and language of the interface (`lc`)[cite: 1482].

* [cite_start]The country code determines that only the products sold in the US are displayed[cite: 1483].
* [cite_start]The language of the interface for the country code US is English[cite: 1484].

The base URL for the write operation is:
[cite_start]`https://us.openfoodfacts.org/cgi/product_jqm2.pl?` [cite: 1486]

#### Product Barcode

[cite_start]After the base URL, the word `code` followed by its barcode must be added[cite: 1488]:
[cite_start]`POST https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004` [cite: 1489]

#### Credentials

[cite_start]Dave adds his user credentials to the call using `user_id` and `password` parameters[cite: 1491, 1492]. [cite_start]Use the `&` to concatenate the parameters[cite: 1493].
[cite_start]`POST https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&user_id=myappname&password=******` [cite: 1492]

#### Parameters

[cite_start]You can define one or more parameters to add, for example, the **brand** and the **Kosher label**[cite: 1495]:
* [cite_start]`brands`: `Häagen-Dazs` [cite: 1496]
* [cite_start]`labels`: `kosher` [cite: 1497]

The complete call with parameters:
[cite_start]`POST https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&user_id=myappname&password=******&brands=Häagen-Dazs&labels=kosher` [cite: 1499]

### Adding a Comment to your WRITE request

[cite_start]Use the **`comment`** parameter to add the ID of the user editing the product[cite: 1501]. [cite_start]The ID should not contain any personal data[cite: 1502].

[cite_start]**Important!** The user ID is not the identifier of an Open Food Facts user, but the ID generated by your system[cite: 1503]. [cite_start]It should be structured as: **user-agent + user-id**[cite: 1504].

**Example:**
[cite_start]`comment=Edit by a Healthy Choices 1.2 iOS user - SxGFRZkFwdytsK2NYaDg4MzRVenNvUEI4LzU2a2JWK05LZkFRSWc9PQ` [cite: 1506]
````