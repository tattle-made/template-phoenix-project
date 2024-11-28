# UliCommunity

This project is a Phoenix template designed to streamline setting up a Phoenix application with built-in authentication and authorization. It supports authentication for both LiveView and non-LiveView components. Additionally, it includes an API server for generating authentication tokens and performing actions securely using a valid token.

## Table of Content

- [Start Development](#start-development)
- [Authentication in Web App itself](#authentication-in-web-app-itself)
   * [Differences between the Authentication with and without the liveview](#differences-between-the-authentication-with-and-without-the-liveview)
   * [Adjustments to make both kind of Authentications work](#adjustments-to-make-both-kind-of-authentications-work)
      + [Changing the Scope of non-liveview routes](#changing-the-scope-of-non-liveview-routes)
- [Authentication with Token](#authentication-with-token)
- [Authorization](#authorization)

## Start Development

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check the deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Authentication in Web App itself

To generate template code for authentication, phoenix provivdes a command `mix phx.gen.auth`. This command provides an option to generate code with either live-view or without live-view.

In this project, we wanted to keep both the kinds of authentication options as a proof of concept. So we first generated the template code with the normal (with no live-view) option, and then generated it with the live-view option.

### Differences between the Authentication with and without the liveview

- The code for non-liveview generated all the relevant routes and their respective controllers.
- The code for liveview generated routes for the liveview templates with their respective controllers inside `/live` folder.
- The genrator did not overwrite the routes, it just added the new routes below the old ones with different macros (live instead of REST macros). But, the routes addresses were same for both the generated routes. Ex- both had `/users/log_in` addresses for their login routes.
- For login they both use the `UserSessionController` controller, and because of this, the genrator for liveview overwrote the code inside this controller. 
- Using the generator generated same migration file for creating the Accounts table twice. (In case of overwiriting a file, the generator always asks for every file).

### Adjustments to make both kind of Authentications work

- The following points are only for authentication routes.

#### Changing the Scope of non-liveview routes
- As the route addresses were same in both the cases, the `scope` for the non-liveview routes was changed from `"/"` to `"/nolive"`. 
- By default, on clicking the registration and login buttons on the homepage, everything will render the liveview templates. To access the similar route for the no-liveview templates prepend `/nolive` to the route. 
  - **NOTE:** While accessing the no-liveview routes, please make sure that the actions the non-liveview templates are calling are also the ones with `/nolive` routes.
  - Example- the `/nolive/users/log_in` route renders the `/controllers/user_session_html/new.html.heex` template, which is a template that renders the login form. So in order to login through the no-liveview way, in the form-action the route has to be changed from `/users/log_in` to `/nolive/users/log_in` to make everything work with no errors (as the routes not starting with "nolive" are liveview routes.)
  - This has already been implemented for the "login" route, but for other similar routes, please check this before testing.

  #### Changes in UserSessionController
  - To address the problem of same `UserSessionController` for both the login routes (liveview and non-liveview), a new `UserSessionLiveController` is created for the liveview login.
  - The `UserSessionController` is now only getting used for the no-liveview routes. 

  #### For Migration files
  - As two migration files were same, one of them was deleted. 

## Authentication with Token

This post was referred while implementing the token functionality: https://dev.to/onpointvn/implement-jwt-authentication-with-phoenix-token-n58

The Token based authentication is implemented to use the project as a service. 

- A separate `/UliCommunity/api` context is created. Inside it there is the `Token` module. 
- The Token module uses `Phoenix.Token` to have sign and verify token function. 
- `Phoenix.Token` is a JSON Web Token.
- For this functinality, separate routes with the scope `/api` is created. 
- A new `AuthenticateApi` plug was also created to authenticate the JWT token. 
- Currently there are only two routes for this functionality. One is `/api/auth/login` and another is `/api/auth/hi`. 
- The login route has nothing to do with login. It is an API endpoint through which users can recieve their token in response if they send request to this route with the right credentials. The controller for that is `SessionControllerApi`. 
- The `"/hi"` route is just a route to test if the authentication is working properly or not. Users can send a Get request to this route with "Bearer AUTH_TOKEN" in the Authentication header, to recieve a simple message. 
- We can use the API context to create more functions and routes to provide different api services to the users. 

## Authorization

- This article was referred to implement the authorization: https://hashrocket.com/blog/posts/authorization-in-phoenix-liveview
- Authorization functionality is implemented with currently two roles "user" and "admin", for a proof of concept. 
- The default role of the user is "admin". Currently, in order to change the role of an user, we have to update it in the database itself.
- Currently we are only implementing the route based authorization, so if a user with the role "user" tries to access an admin route, that would not be allowed. 
- A new context for Authorization is created in `/uli_comminity/authorization`.
- Here we can add more routes which need to implement the authorization.
- Other changes include changes in the router to include `on_mount` functions and changes in the `user_auth` module to create a new `on_mount` function.