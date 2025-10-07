# Introduction to Open Food Facts API Documentation

-----

**[\!CAUTION]** Are you going to use our API? [cite\_start]Please read this documentation entirely before using it[cite: 77].

## Overview

[cite\_start]**Open Food Facts** is a food products database made by everyone, for everyone, that can help you make better choices about what you eat[cite: 79]. [cite\_start]Being **open data**, anyone can reuse it for any purpose[cite: 80].

[cite\_start]The Open Food Facts API enables developers to get information like ingredients and nutritional values of products, and even add more facts to the products database[cite: 81]. [cite\_start]You can use the API to build applications that allow users to contribute to the database and make healthier food choices[cite: 82].

  * [cite\_start]The **current version** of the API is **2**[cite: 83].
  * [cite\_start]The **next version** of the API is **3**, which is in active development and may be subject to frequent changes[cite: 87, 88].

[cite\_start]**Data Reliability:** Data is provided voluntarily by users[cite: 84]. [cite\_start]As a result, there are **no assurances** that the data is accurate, complete, or reliable, and the user assumes the entire risk of using the data[cite: 85, 86].

-----

## Before You Start

The Open Food Facts database and its contents are available under open licenses:

  * [cite\_start]The Open Food Facts database is available under the **Open Database License**[cite: 90].
  * [cite\_start]The individual contents of the database are available under the **Database Contents License**[cite: 91].
  * [cite\_start]Product images are available under the **Creative Commons Attribution ShareAlike license**[cite: 92]. [cite\_start]They may contain graphical elements subject to copyright or other rights[cite: 93].

Before using the API, please:

1.  [cite\_start]Read the **Terms and conditions of use and reuse**[cite: 95].
2.  [cite\_start]Tell us how you'll use it by filling out this short form: 👉 **Fill out the API usage form**[cite: 96]. [cite\_start]This helps Open Food Facts understand real-world uses and prioritize improvements[cite: 96].

-----

## How to Best Use the API

### General principles

[cite\_start]You can search for product information, including many useful computed values[cite: 99]. [cite\_start]If the information you need isn't available for a specific product, you (or your users) can upload product photos, and the backend and AI algorithms will process them to generate helpful info[cite: 100, 101]. [cite\_start]These photos will also be available to other API users and Open Food Facts users[cite: 102]. [cite\_start]The more information available about a product, the more that can be computed[cite: 104].

[cite\_start]You could also ask your user to enter some information about the product (like name, category, and weight) so that they immediately get the computed info[cite: 103].

### Rate limits

[cite\_start]To protect the infrastructure, rate-limits are enforced on the API and website[cite: 106]. [cite\_start]If these limits are reached, Open Food Facts reserves the right to deny access via IP address ban[cite: 112]. [cite\_start]If your IP is banned, you can email them to explain why, and reverting the ban is possible[cite: 113].

The following limits apply:

  * [cite\_start]**100 req/min** for all **read product queries** (`GET /api/v*/product` requests or product page)[cite: 107].
  * [cite\_start]There is **no limit** on product **write queries**[cite: 108].
  * [cite\_start]**10 req/min** for all **search queries** (`GET /api/v*/search` or `GET /cgi/search.pl` requests)[cite: 109]. [cite\_start]**Do not use this for a search-as-you-type feature**, or you will be blocked quickly[cite: 110].
  * [cite\_start]**2 req/min** for **facet queries** (such as `/categories`, `/label/organic`, etc.)[cite: 111].

[cite\_start]If your requests come from your users directly (e.g., a mobile app), the rate limits apply **per user**[cite: 114].

**For bulk data/images:**

  * [cite\_start]If you need to fetch a significant fraction of the database, it's recommended to **download the data as a CSV or JSONL file** directly[cite: 115].
  * [cite\_start]If you need to download images in bulk, a guide is available for that[cite: 116].

### If your users do not expect a result immediately (e.g., Inventory apps)

[cite\_start]The most painless contribution for users is to **submit photos** (front packaging/nutrition values/ingredients)[cite: 118]. [cite\_start]The backend (Product Opener) and Open Food Facts AI (Robotoff) will generate some derived data from the photos, and the Open Food Facts community will fill the data gaps over time[cite: 119, 120].

### If your users expect a result immediately (e.g., Nutrition apps)

You can submit product information to get computed scores:

  * [cite\_start]If you submit the product's nutritional values and category, you'll get the **Nutri-Score**[cite: 122].
  * [cite\_start]If you submit the product ingredients, you'll get the **NOVA group** (about food ultra-processing), additives, allergens, and more[cite: 123].
  * [cite\_start]If you submit the product's category and labels, you'll get the **Eco-Score** (a rating of the product's environmental impact)[cite: 124].

-----

## API Deployments

[cite\_start]The Open Food Facts API has two deployments[cite: 126]:

  * [cite\_start]**Production:** `https://world.openfoodfacts.org` [cite: 127]
  * [cite\_start]**Staging:** `https://world.openfoodfacts.net` [cite: 128]

[cite\_start]If you are not in a production scenario, consider using the staging environment, and make all API requests to staging while testing your applications[cite: 129, 130]. [cite\_start]This helps ensure the product database is safe[cite: 131].

[cite\_start]**Staging Environment Authentication:** The staging environment requires **HTTP Basic Auth** to avoid search engine indexing[cite: 132]. [cite\_start]The username is **`off`** and the password is **`off`**[cite: 132].

Example JavaScript code for testing in the browser console:

````javascript
fetch("https://world.openfoodfacts.net/api/v2/product/3274080005003.json", {
  method: "GET",
  headers: { Authorization: "Basic " + btoa("off:off") },
})
.then((response) => response.json())
.then((json) => console.log(json));
[cite_start]``` [cite: 134, 135, 136, 137, 138, 139]

---

## Authentication

### User-Agent

[cite_start]You are asked to **always use a custom User-Agent** to identify your app and not risk being identified as a bot[cite: 141].
* [cite_start]The User-Agent should be in the form of `AppName/Version (ContactEmail)`[cite: 142].
* [cite_start]Example: `MyApp/1.0 (myapp@example.com)`[cite: 142].

[cite_start]**READ operations** (getting product info) do not require authentication other than the custom User-Agent[cite: 143].

### WRITE Operations

[cite_start]**WRITE operations** (editing a product, uploading images) require authentication as a layer of protection against spam[cite: 144]. [cite_start]You should create an account on the Open Food Facts app for your application and fill out the API usage form[cite: 145].

There are two options for authentication:

1.  [cite_start]**Preferred: Session Cookie** [cite: 147]
    * [cite_start]Use the login API to get a session cookie, and then use this cookie for authentication in subsequent requests[cite: 147].
    * [cite_start]**Caveats:** The session must always be used from the same IP address, and there's a limit on sessions per user (currently 10), with older sessions being automatically logged out[cite: 148].

2.  [cite_start]**Credentials in Parameters** [cite: 149]
    * [cite_start]If session conditions are too restrictive, include your account credentials as parameters for authenticated requests (do this only on **POST / PUT / DELETE** requests, not on GET)[cite: 149].
    * [cite_start]Parameters are: `user_id` (your username, **not your email address**) and `password`[cite: 149, 159].

[cite_start]You can create a **global account** for your app to allow your users to contribute without registering individual accounts on the website, ensuring contributions are traced back to your application[cite: 150, 151]. [cite_start]In this case, you are asked to send the following parameters in your write queries[cite: 152]:
* [cite_start]`app_name=MyApp` [cite: 153]
* [cite_start]`app_version=1.1` [cite: 154]
* [cite_start]`app_uuid=xxxx`: a salted random UUID for the user so that moderators can selectively ban any problematic user without banning your whole app account[cite: 155].

[cite_start]**Deployment Accounts:** Production and staging have different account databases, so you'll need to create a separate account for the staging environment if you want to perform WRITE requests there[cite: 156, 157].

[cite_start]**Note:** Open Food Facts is currently moving to a modern Auth system (Keycloak), and new authentication options are expected soon[cite: 158].

---

## Reference Documentation and Help

### Reference Documentation (OpenAPI)
[cite_start]Open Food Facts is building a complete OpenAPI reference[cite: 161]. Current documentation available includes:
* [cite_start]OpenAPI documentation (v2) [cite: 162]
* [cite_start]OpenAPI documentation for v3 (under active development) [cite: 163]
* [cite_start]A cheatsheet listing some common patterns [cite: 164]
* [cite_start]A change log for the API and product schema [cite: 165]

### Tutorials
* [cite_start]A comprehensive introduction to Using the Open Food Facts API[cite: 167].
* [cite_start]Uploading images to the Open Food Facts API[cite: 168].

### Help
* [cite_start]Try the **FAQ** to answer most questions[cite: 170].
* [cite_start]Contact the Team on the **#api Slack Channel**[cite: 171].
* [cite_start]Report **Bugs** on the Open Food Facts **GitHub repository**[cite: 172].
* [cite_start]You can submit an **issue or feature request** on GitHub[cite: 173].
* [cite_start]See the **Contribution Guidelines** if you are interested in contributing to the project[cite: 174].

---

## SDKs

[cite_start]SDKs are available for specific languages to make API use easier[cite: 176]. [cite_start]If a wrapper exists for your favorite language, you can use and improve it; if not, you can help create it[cite: 177, 178]. [cite_start]These SDKs let you consume data and let your users contribute new data[cite: 179].

[cite_start]**Warning:** Before exploring any SDK, read the "Before You Start" section[cite: 182]. [cite_start]Also, check the API Reference Documentation first to verify if the problem is in the SDK implementation or the API itself[cite: 183].

[cite_start]SDKs are open-source and developed by contributors, so more contributions are welcome to improve them[cite: 180]. [cite_start]You can check the existing issues in their respective repositories[cite: 181].

| Language/Framework | Repository and Package |
| :--- | :--- |
| **Cordova** | [cite_start]GitHub (old Open Food Facts official app) [cite: 184] |
| **DART** | [cite_start]GitHub - Package on pub.dev [cite: 185] |
| **Elixir** | [cite_start]GitHub - Discussion channel [cite: 186] |
| **Go** | [cite_start]GitHub - Discussion channel [cite: 187] |
| **Java** | [cite_start]GitHub - Discussion channel [cite: 188] |
| **Spring Boot** | [cite_start]GitHub - Discussion channel [cite: 189] |
| **Kotlin** | [cite_start]GitHub - Discussion channel [cite: 190] |
| **NodeJS** | [cite_start]GitHub - Discussion channel [cite: 191] |
| **PHP** | [cite_start]GitHub - Discussion channel [cite: 192] |
| **PHP (Laravel)** | [cite_start]GitHub - Discussion channel [cite: 193] |
| **Python** | [cite_start]GitHub, published on pypi - Discussion channel [cite: 194] |
| **React Native** | [cite_start]GitHub - Discussion channel [cite: 195] |
| **Ruby** | [cite_start]GitHub - Discussion channel [cite: 196] |
| **Rust** | [cite_start]GitHub - Discussion channel [cite: 197] |
| **R** | [cite_start]GitHub - Discussion channel [cite: 198] |
| **Swift** | [cite_start]GitHub - Discussion channel [cite: 199] |
| **.NET/C#** | [cite_start]GitHub - Discussion channel [cite: 200] |
````