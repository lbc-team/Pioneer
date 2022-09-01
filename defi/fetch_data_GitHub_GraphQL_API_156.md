原文链接：https://jpreagan.medium.com/four-ways-to-fetch-data-from-the-github-graphql-api-in-next-js-596dd13307eb

# Four ways to fetch data from the GitHub GraphQL API in Next.js

视频来源：https://youtu.be/Bly6ek8sR9g

Four Ways to fetch data from the GitHub GraphQL API in Next.js

> *There are several ways to render fetched data in Next.js. One of the great features of Next.js is we can mix and match rendering methods within our application. Using this hybrid approach, we have great flexibility. In this post, I will cover four ways to render fetched data from the GitHub GraphQL API in a Next.js application. You’ll learn the benefits and drawbacks of each option, and you’ll walk away knowing when to consider each one in writing your own application.*

There is a [GitHub repository](https://github.com/jpreagan/github-graphql-nextjs-example) available, and also a [live demo](https://github-graphql-nextjs-example.vercel.app/) to check out.

## What is Next.js and why should I use it?

React is an open-source JavaScript library developed by Facebook designed to build interactive user interfaces. React has become the most widely used and popular choice in the JavaScript world with this purpose in mind.

Next.js is a React framework for making performant web applications. Next.js will save you a lot of time and will give you capability and optimization that is difficult to compete with. It is built with performance and developer experience in mind. Out of the box, we get features like advanced image optimization, routing, backend functionality, internationalization, and built-in CSS support to name a few.

In 2022, it’s the best and easiest way to get started with a React application.

## What are my rendering options in Next.js?

A rendering option determines when a page’s HTML is generated. We can pre-render pages or we can render them locally in the browser.

In Next.js, we have the following rendering options:

- Client-side rendering
- Server-side rendering
- Static site generation
- Incremental static regeneration

Let’s take a look at how each of these work.

## Client side rendering

If you’re familiar with React, chances are you’ve probably already employed the `useEffect` hook to fetch data. Because Next.js is a React framework, anything we can normally do in React we can also do with Next.js.

```
import React, { useState, useEffect } from "react";function App() {
  const [users, setUsers] = useState([]);  useEffect(() => {
    const fetchUsers = async () => {
      const response = await fetch("/api/users");
      const data = await response.json();
      setUsers(data);
    };
    fetchUsers();
  }, [setUsers]);  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}export default App;
```

When this component mounts, we’ll fetch data from the `/api/users` endpoint and render. That fetch and render is done by the client, so we call it client-side rendering.

Client-side rendering is the preferred method where the priority is on response time during interactions. Dynamic, client-side rendered components will appear to the user as an empty area or blank screen until the data is fetched.

Lucky for us, at least parts of a page may be sent statically while these components fetch data in Next.js. We can improve the experience by letting the user know the data is being loaded and also handle any errors.

```
import React, { useState, useEffect } from "react";function App() {
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [hasError, setHasError] = useState(false);  useEffect(() => {
    const fetchUsers = async () => {
      setIsLoading(true);
      setHasError(false);
      try {
        const response = await fetch("/api/users");
        const data = await response.json();
        setUsers(data);
      } catch (error) {
        setHasError(true);
      }
      setIsLoading(false);
    };
    fetchUsers();
  }, [setUsers]);  return (
    <>
      {hasError && <p>Oops! Something went wrong :(</p>}
      {isLoading ? (
        <p>Loading...</p>
      ) : (
        <ul>
          {users.map(user => (
            <li key={user.id}>{user.name}</li>
          ))}
        </ul>
      )}
    </>
  );
}export default App;
```

Even slicker would be to give them a circle spinning thing. It’s a bit more visually appealing than a `Loading...` text. You may write your own or check out a project like React Spinners.

There are, however, a few downsides to client-side rendering. As the JavaScript bundle size increases, key performance metrics like First Paint (FP), First Contentful Paint (FCP), and Time to Interactive (TTI) suffer more and more. In other words, our app gets slower and the burden is put on the client.

Also, you won’t get good search engine visibility with client-side rendering. This issue can be a real problem if you have an ecommerce store, for example, and desire to have your products indexed by search engines. The same might be said for blog posts. But even so, this might be an unnecessary and undesirable consideration, for example, in the case of a logged-in user’s dashboard.

## Server-side rendering

Server-side rendering generates pages on each request. In other words, the user enters a URL in the browser, hits send, the server receives the request, processes the page, and serves up a fresh, pre-rendered page to the user’s browser.

In Next.js, we can take advantage of server-side rendering with `getServerSideProps`. Note this method will only work at the page level, unlike client-side rendering which can be used in pages or components.

```
function Page({ data }) {
  // Render data...
}// This gets called on every request
export async function getServerSideProps() {
  // Fetch data from external API
  const res = await fetch(`https://.../data`);
  const data = await res.json();  // Pass data to the page via props
  return { props: { data } };
}export default Page;
```

The burden of fetching and rendering is put on the server. The aforementioned performance metrics, First Paint (FP), First Contentful Paint (FCP), and Time to Interactive (TTI), will see an improvement. This performance boost grows as the data gets larger and the amount of JavaScript increases.

The user will not have to wait for the page to become interactive, because it has just been pre-rendered for them on the server. No more circle spinning thing.

But like everything, there is a tradeoff. The Time to First Byte (TTFB) can suffer. TTFB measures the length of time between requesting a page and when the first byte of data reaches the user. I wouldn’t want to use server-side rendering without a Content Delivery Network (CDN) like Cloudflare, Fastly, Vercel, etc. And in a future post, I’ll cover making use of HTTP caching directives that can mitigate a lot of this downside.

Finally, web crawlers will be able to index server-side rendered pages like it’s the good old days again. Search engine visibility is perfect with server-side rendering, and this is something to bear in mind when it comes time to choose a rendering method.

## Static site generation

If your data does not change often, for example, a blog post: use static site generation. Server-side rendering prepares a page to be sent to the user upon request. By contrast, static site generation prepares those pages at build time.

You will never beat the speed and reliability of static pages. They are prepped and ready to go, and can be cached on your CDN for the best possible performance. All performance metrics, including TTFB, will be unmatched by any other method. The search engine visibility is also perfect.

For this reason, I would make it your default option and use it whenever possible. If the data changes frequently, however, then you’ll have to go with another method.

In Next.js, we make use of static site generation with `getStaticProps`:

```
// posts will be populated at build time by getStaticProps()
function Blog({ posts }) {
  return (
    <ul>
      {posts.map(post => (
        <li>{post.title}</li>
      ))}
    </ul>
  );
}// This function gets called at build time on server-side.
// It won't be called on client-side, so you can even do
// direct database queries.
export async function getStaticProps() {
  // Call an external API endpoint to get posts.
  // You can use any data fetching library
  const res = await fetch("https://.../posts");
  const posts = await res.json();  // By returning { props: { posts } }, the Blog component
  // will receive `posts` as a prop at build time
  return {
    props: {
      posts,
    },
  };
}export default Blog;
```

## Incremental static regeneration

The new kid on the block is incremental static regeneration. Let’s say you have a blog with thousands of posts or an ecommerce store with 100,000 products, and we’re using SSG for superior performance and search engine visibility. Build time might take hours in some cases.

This situation is impractical and because servers cost money, either your servers or someone else’s, we pay for computation and bandwidth. Incremental static regeneration was designed as a solution to this problem.

With incremental static regeneration, you can prerender specified pages in the background while receiving requests. In Next.js, to use incremental static regeneration, add the `revalidate` prop to `getStaticProps`:

```
function Blog({ posts }) {
  return (
    <ul>
      {posts.map(post => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}// This function gets called at build time on server-side.
// It may be called again, on a serverless function, if
// revalidation is enabled and a new request comes in
export async function getStaticProps() {
  const res = await fetch("https://.../posts");
  const posts = await res.json();  return {
    props: {
      posts,
    },
    // Next.js will attempt to re-generate the page:
    // - When a request comes in
    // - At most once every 10 seconds
    revalidate: 10, // In seconds
  };
}// This function gets called at build time on server-side.
// It may be called again, on a serverless function, if
// the path has not been generated.
export async function getStaticPaths() {
  const res = await fetch("https://.../posts");
  const posts = await res.json();  // Get the paths we want to pre-render based on posts
  const paths = posts.map(post => ({
    params: { id: post.id },
  }));  // We'll pre-render only these paths at build time.
  // { fallback: blocking } will server-render pages
  // on-demand if the path doesn't exist.
  return { paths, fallback: "blocking" };
}export default Blog;
```

## A gentle introduction to GraphQL

Next, let’s talk about GraphQL. What is it? GraphQL is a query language and server-side runtime for application programming interfaces (APIs). With GraphQL, we can make a request for the data we want and be sent exactly that: nothing more or less.

You may be familiar with traditional REST APIs in which you hit up an endpoint and you’re given a set of data that is determined by how the API is programmed. You might have to fetch data from multiple endpoints to get everything you need at that time, and then throw out bits of excess data that you don’t want.

We don’t have to do that with GraphQL. That is one of GraphQL’s most appealing features.

Some folks get a bit intimidated getting started with GraphQL because it seems complex. But it’s just a specification that glues together existing network technology. It is rather intuitive once you have a chance to play.

You don’t need any special tools to make GraphQL requests.

Let’s see how simple it can be by making a request from the command line:

```
curl --request POST \
  --header 'content-type: application/json' \
  --url 'https://flyby-gateway.herokuapp.com/' \
  --data '{"query":"query { locations { id, name } }"}'
```

Notice we are making a `POST` request as we have to send our query to the server. GraphQL servers have a single endpoint. In our request body we communicate which data we want, and we’ll be given exactly that in return.

In this case, we receive the following JSON:

```
{"data":{"locations":[{"id":"loc-1","name":"The Living Ocean of New Lemuria"},{"id":"loc-2","name":"Vinci"},{"id":"loc-3","name":"Asteroid B-612"},{"id":"loc-4","name":"Krypton"},{"id":"loc-5","name":"Zenn-la"}]}
```

How does that look in a React application? There are numerous GraphQL clients we can use, [Apollo Client](https://www.apollographql.com/docs/react/), [Relay](https://relay.dev/), or [urql](https://formidable.com/open-source/urql/) to mention a few, but to get started we can also use something as simple as the browser’s Fetch API:

```
import React, { useState, useEffect } from "react";const url = `https://flyby-gateway.herokuapp.com/`;const gql = `
  query {
    locations {
      id
      name
    }
  }
`;function App() {
  const [locations, setLocations] = useState([]);  useEffect(() => {
    const fetchLocations = async () => {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query: gql,
        }),
      });
      const {
        data: { locations: data },
      } = await response.json();
      setLocations(data);
    };
    fetchLocations();
  }, [setLocations]);  return (
    <ul>
      {locations.map(location => (
        <li key={location.id}>{location.name}</li>
      ))}
    </ul>
  );
}export default App;
```

## The GitHub GraphQL API

Now, let’s move on to looking at the [GitHub GraphQL API](https://docs.github.com/en/graphql). GitHub has a REST API and a GraphQL API. We’ll focus on the GraphQL API here.

Grab an [access token](https://github.com/settings/tokens) first as we will need to be authenticated to make requests. As for defining the scope of your token, I recommend you start with the following:

```
repo
read:packages
read:org
read:public_key
read:repo_hook
user
read:discussion
read:enterprise
read:gpg_key
```

The API will let you know if you need more.

Let’s do another request from the command line with `curl`:

```
curl -H "Authorization: bearer token" -X POST -d " \
 { \
   \"query\": \"query { viewer { login }}\" \
 } \
" https://api.github.com/graphql
```

Replace `token` with token string you just generated.

We get something back like:

```
{ "data": { "viewer": { "login": "jpreagan" } } }
```

Hey, that’s me! By using your token, you’ll see your username there too. Great! Now we know it works.

Bear in mind we want to keep this token private and make sure it doesn’t make it into our repo. We’ll keep it in a file like `.env.local`. That file should look something like this:

```
GITHUB_TOKEN=mytoken
```

Where mytoken is the string you generated.

Now we can access it via `process.env.GITHUB_TOKEN` with built-in support for environmental variables in Next.js. We won’t be able to securely access these variables though by just putting them in the headers of the above examples. We’ll need to use `getServerSideProps`, `getStaticProps`, or use [API Routes](https://nextjs.org/docs/api-routes/introduction) which I’ll cover shortly.

For now, though let’s look at the [GitHub GraphQL Explorer](https://docs.github.com/en/graphql/overview/explorer). This is an instance of GraphiQL, which is a handy tool for making GraphQL queries in the browser.

The best way to get acquainted with it is just to play around with it for a bit. This is the query I came up with as to what I think I might need:

```
query {
  viewer {
    login
    repositories(
      first: 20
      privacy: PUBLIC
      orderBy: { field: CREATED_AT, direction: DESC }
    ) {
      nodes {
        id
        name
        description
        url
        primaryLanguage {
          color
          id
          name
        }
        forkCount
        stargazerCount
      }
    }
  }
}
```

As your data requirements change, you can return to the GraphQL explorer, update, and test those queries, which you can copy and paste back into your code. This experience, in my opinion, is a lot nicer than wading through REST API documentation.

## Client-side rendering

Now let’s return to our example of client-side rendering. Let’s revamp the `fetchUsers` example from above, but we’ll do a few things differently.

First of all, as I mentioned, we can’t just put our access tokens in the headers of our original code. That will be sent to the client and anyone can just open the network tab and read your access tokens making them exposed and insecure.

Instead, we can place them in `getServerSideProps` or `getStaticProps` and they are secure there, but that would be for server-side rendering and static site generation respectively. We’ll make use of another fabulous feature of Next.js here called API Routes.

In short, we can make a JavaScript or TypeScript file in the `pages/api` directory that will serve as an API endpoint. They will not be delivered to the client and are therefore a secure way to hide our access tokens and one of the only options we have to do so in client-side rendering.

(Another option would be to make a serverless function on another service such as an AWS Lambda function, but I won’t cover that here. Why do that when we have a perfectly good solution built into Next.js.)

Here is a basic example: `pages/api/hello.js`:

```
export default function handler(req, res) {
  res.status(200).json({ message: 'Hello, World! })
}
```

Now, with our development server running, we can `curl http://localhost:3000/hello`, and we’re greeted with:

```
{ "message": "Hello, World!" }
```

I find this totally awesome! All we need to do is export a default function request handler (called `handler`), which receives two parameters: `req` and `res`. This isn’t Express, but you will notice the syntax is Express-like. How cool is that?

So, let’s write an endpoint with our client-side rendering purposes in mind:

```
// src/pages/github.ts
import type { NextApiRequest, NextApiResponse } from "next";
import { GraphQLClient, gql } from "graphql-request";export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  const endpoint = "https://api.github.com/graphql";  const client = new GraphQLClient(endpoint, {
    headers: {
      authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
    },
  });  const query = gql`
    {
      viewer {
        login
        repositories(
          first: 20
          privacy: PUBLIC
          orderBy: { field: CREATED_AT, direction: DESC }
        ) {
          nodes {
            id
            name
            description
            url
            primaryLanguage {
              color
              id
              name
            }
            forkCount
            stargazerCount
          }
        }
      }
    }
  `;  const {
    viewer: {
      repositories: { nodes: data },
    },
  } = await client.request(query);  res.status(200).json(data);
}
```

I mentioned already we can use just about any client want when fetching GraphQL data. Prisma’s [graphql-request](https://github.com/prisma-labs/graphql-request) is a simple and lightweight option, and that is what I’ve used here.

With this code in place, we can test our endpoint out with a `curl http://localhost.com/api/github` and we’ll now get our data. Hooray, now let’s write the frontend part of this equation.

```
// src/pages/csr.tsx
import type { NextPage } from "next";
import type { Repository } from "../types";
import useSWR from "swr";
import Card from "../components/card";interface ApiError extends Error {
  info: any;
  status: number;
}const fetcher = async (url: string) => {
  const response = await fetch(url);  if (!response.ok) {
    const error = new Error(
      "An error occurred while fetching the data"
    ) as ApiError;
    error.info = await response.json();
    error.status = response.status;
    throw error;
  }  const data = await response.json();  return data;
};const Csr: NextPage = () => {
  const { data, error } = useSWR<Repository[], ApiError>(
    "/api/github",
    fetcher
  );  if (error) return <div>Something went wrong :(</div>;
  if (!data) return <div>Loading...</div>;  return (
    <>
      {data.map(
        ({
          id,
          url,
          name,
          description,
          primaryLanguage,
          stargazerCount,
          forkCount,
        }) => (
          <Card
            key={id}
            url={url}
            name={name}
            description={description}
            primaryLanguage={primaryLanguage}
            stargazerCount={stargazerCount}
            forkCount={forkCount}
          />
        )
      )}
    </>
  );
};export default Csr;// src/components/card.tsx
import type { Repository } from "../types";const Card = ({
  url,
  name,
  description,
  primaryLanguage,
  stargazerCount,
  forkCount,
}: Repository) => {
  return (
    <>
      <article>
        <h2>
          <a href={url}>{name}</a>
        </h2>
        <p>{description}</p>
        <p>
          {primaryLanguage && (
            <span style={{ backgroundColor: primaryLanguage?.color }}>
              {primaryLanguage?.name}
            </span>
          )}
          {stargazerCount > 0 && (
            <a href={`${url}/stargazers`}>{stargazerCount}</a>
          )}
          {forkCount > 0 && <a href={`${url}/network/members`}>{forkCount}</a>}
        </p>
      </article>
    </>
  );
};export default Card;
```

We’re using [SWR](https://swr.vercel.app/) here to fetch. This is a tool by Vercel derived from the `stale-while-revalidate` HTTP caching directive made popular in RFC 5861. SWR will return cached data (stale), then send the fetch request (revalidate), and finally arrive with updated data.

It is fast, lightweight, handles caching, and we can employ it with any protocol. We can use this hook by giving it our endpoint and a fetcher function which we’ve defined above.

Let’s test out the time to first byte (TTFB) of this code deployed:

```
curl --output /dev/null \
     --header 'Cache-Control: no-cache' \
     --silent \
     --write-out "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" \
     https://github-graphql-nextjs-example.vercel.app/csr
```

We get the results:

```
Connect: 0.082094 TTFB: 0.249804 Total time: 0.250051
```

Not bad! Bear in mind a few things: (a) I live on a rural island in the middle of the Pacific (the numbers are fantastic for my location), (b) caching is turned off, and © this is the time to the first byte, but we get a `Loading...` until the data is actually fetched; then the client must re-render.

## Server-side rendering

How does that look using server-side rendering? We’re going to make use of `getServerSideProps`. Let’s check out how that looks.

```
import type { Repository } from "../types";
import { GraphQLClient, gql } from "graphql-request";
import Card from "../components/card";type SsrProps = {
  data: Repository[];
};const Ssr = ({ data }: SsrProps) => {
  return (
    <>
      {data.map(
        ({
          id,
          url,
          name,
          description,
          primaryLanguage,
          stargazerCount,
          forkCount,
        }) => (
          <Card
            key={id}
            url={url}
            name={name}
            description={description}
            primaryLanguage={primaryLanguage}
            stargazerCount={stargazerCount}
            forkCount={forkCount}
          />
        )
      )}
    </>
  );
};export async function getServerSideProps() {
  const endpoint = "https://api.github.com/graphql";  const client = new GraphQLClient(endpoint, {
    headers: {
      authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
    },
  });  const query = gql`
    {
      viewer {
        login
        repositories(
          first: 20
          privacy: PUBLIC
          orderBy: { field: CREATED_AT, direction: DESC }
        ) {
          nodes {
            id
            name
            description
            url
            primaryLanguage {
              color
              id
              name
            }
            forkCount
            stargazerCount
          }
        }
      }
    }
  `;  const {
    viewer: {
      repositories: { nodes: data },
    },
  } = await client.request(query);  return { props: { data } };
}export default Ssr;
```

It works the same as we did in our client-side rendering above with API Routes, but instead this time we are using `getServerSideProps`. The access token will be safe there as it is only accessible by the backend and is never sent to the client.

Just for your peace of mind, you can use the [Next.js Code Elimination tool](https://next-code-elimination.vercel.app/) to verify what is being sent to the client.

Let’s check out that time to first byte now:

```
curl --output /dev/null \
     --header 'Cache-Control: no-cache' \
     --silent \
     --write-out "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" \
     https://github-graphql-nextjs-example.vercel.app/ssrConnect: 0.074334 TTFB: 0.504285 Total time: 0.505289
```

OK, the TTFB has bumped up now, but again bear all these things in mind: (a) the page is being sent to the client pre-rendered, there is no `Loading...`, and (b) this is without caching which could potentially speed things up by quite a lot.

The data is fresh as of the moment it was requested too! The user will need to hit refresh on the browser, however, if the data were to change.

## Static site generation

Let’s look at static site generation now.

We’re only going to make one tiny change to the server-side rendering code: we’ll use `getStaticProps` instead of `getServerSideProps`:

```
/* ... */
const Ssg = ({ data }: SsgProps) => {
  return (/* ... */);
};export async function getStaticProps() {
  /* ... */
}export default Ssg;
```

That’s it! Now our page will be pre-rendered at build time. How does the time to first byte look?

```
curl --output /dev/null \
     --header 'Cache-Control: no-cache' \
     --silent \
     --write-out "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" \
     https://github-graphql-nextjs-example.vercel.app/ssg
Connect: 0.073691 TTFB: 0.248793 Total time: 0.250743
```

Not bad, looks like we matched the time of our client-side rendering, but we’re serving up a pre-rendered page. No further requests once the page is received, all other performance metrics will be superior, it’s the most reliable of any of the options, and the search engine visibility is at its best too.

What’s the downside? Well, the data is fetched at build time. So, if the data is updated after the build we’ll be serving stale data, but this next option might help with that.

## Incremental static regeneration

Finally, let’s look at incremental static regeneration. We can take the exact same code from our static site generation, and add a `revalidate` prop.

```
/* ... */const Isr = ({ data }: IsrProps) => {
  return (/* ... */);
};export async function getStaticProps() {
  /* ... */
  return {
    props: {
      data,
    },
    revalidate: 5,
  };
}export default Isr;
```

The `revalidate` prop is a time measurement in seconds that lets the server know how long until the data is considered stale. At build time, we’ll have a page pre-rendered as per normal with static site generation, and when a user requests a new page, we’ll give them that and check for staleness. If stale, then revalidate: a new copy will be made.

How cool! Now we can have the best of both worlds.

The time to first byte is as expected on par with static site generation:

```
curl --output /dev/null \
     --header 'Cache-Control: no-cache' \
     --silent \
     --write-out "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" \
     https://github-graphql-nextjs-example.vercel.app/isrConnect: 0.076293 TTFB: 0.255100 Total time: 0.255657
```

## Wrapping up

Those are four ways to render fetched data in Next.js. You can check out the [GitHub repository](https://github.com/jpreagan/github-graphql-nextjs-example), clone it, use your access token, and take it for a test spin. Or check out the [live demo](https://github-graphql-nextjs-example.vercel.app/).

Leave a star on the repo if you found it useful! As always, reach out to me on [Twitter](https://twitter.com/jpreagan_) if I can be of any assistance.