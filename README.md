# Advanced Databse Management Systems

**Team name: Docker**  
**App name: Reads**  
**Team members: Zhassulan, Adilet, Ilyas**  

## Read books, get points!

### Project goal and its applications

We know all the knowledge can be found in books. Our goal is to make an app that can awaken the desire of people to read. In our app, users can get points from reading a book, and for top readers there could be prizes.

### Project functions and features:
User: 
  1. Read books, leave review
  2. Get points for your books and reviews
  3. Show users rating
  4. Authorization
  
Admin:  

  &emsp;5. Upload, Delete, Edit books   
  &emsp;7. Create, Delete, Edit rules

### Programming language and database server:
1. For mobile application we are going to use Flutter framework, because it is cool framework to make app for both platforms IOS and Android, the code is written in Dart.
2. For backend we are going to use Spring framework with Kotlin language. This framework has big amount of tools and features and it's easy to connect with database and send data to Front with APIs.
3. We are going to use PostgreSQL Database for our project, because it is the best database ever :D


## Questions over the data and project
1. What are book lots?

2. By what criteria will the reader raise the rating?
 
3. Who are our users?

4. What roles and are available (permissions) in the library?

5. How can user authorize or sign in?
 
6. How the user leave a review for the finished book?
 
7. How the user gain, collect points from his/her review?
 
8. How to create, edit and delete rules, guiedes of the application?
 
9. How to create, edit and delete books of the library?
 
10. What roles user has and what can they do?
 
11. How the user can search some book by its title, author, category?
 
12. How the user can get set of books by filters?
 
13. How user can share his/her favourite book name with others?
 
14. How rating of books calculates?
 
15. When and how user finishes the book and leave feedback, rating to finished book?

## Dataset for the project:
The idea in our project is users should request for admin user account and password. We have datasets of books, rules, and data of users which are reading a special book, and users profile data. But in **datasets** folder, we can not share user account datas, because its private datas. 

 
 ## UseCase UML Diagram:
 
![alt text](https://github.com/suiebay/db_project/blob/main/Docker-UseCase-UML.png)


## UI implementation and DB connection:  

  * #### Application UI was created by Flutter and source code you can see in [user-interface-noble-app](https://github.com/suiebay/db_project/tree/main/user-interface-noble-app) directory, see screenshots below:  

<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3459.PNG" width="200" height="430"> | <img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3460.PNG" width="200" height="430">
<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3461.PNG" width="200" height="430">
<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3462.PNG" width="200" height="430"> 
<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3463.PNG" width="200" height="430">
<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3464.PNG" width="200" height="430">
<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3465.PNG" width="200" height="430">
<img src="https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/IMG_3466.PNG" width="200" height="430">  

  * #### Connection to the database is in [application.properties](https://github.com/suiebay/db_project/blob/main/spring-boot-v1-db_project/src/main/resources/application.properties) file of our spring-boot backend, see screenshot below: 

![alt text](https://github.com/suiebay/db_project/blob/main/user-interface-screenshots/DB%20Connection.png)

## SQL to Relational Algebra  

You can see our SQL Queries in RA Operators at the following link: [**RA Operators**](https://github.com/suiebay/db_project/tree/main/RA%20Operators)

## Query Speed Performance

Measured and provided the runtime of each project funtionality and the time values in milliseconds: [**Runtime and Time Values**](https://github.com/suiebay/db_project/tree/main/Sql_speed_tester)  

Provided the query optimization and execution times (in ms) for the 7 queries (bonus points). Used PostgreSQL EXPLAIN
ANALYZE features that allows to see execution plan details including the time spent on the optimization: [**Query Optimization**](https://github.com/suiebay/db_project/tree/main/SQL%20Analyzation)
