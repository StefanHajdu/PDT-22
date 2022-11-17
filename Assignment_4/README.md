## Úloha 1

Najdi tweet od Zelenskyho s najvacsim poctom vztahov REPLIED_TO

**Výsledné Query:**

```SQL
CALL {
MATCH (zelensky:Author {username: 'ZelenskyyUa'})-[rel:TWEETED]->(ZelenskyTweet:Conversation)<-[reply:REPLIED_TO]-(otherTweet:Conversation)
WITH ZelenskyTweet, otherTweet, reply
RETURN ZelenskyTweet, size(collect(reply)) as cnt
ORDER BY cnt DESC
LIMIT 1
}
CREATE (StefanHajdu:Author {name: 'StefanHajdu', username:'sh00066'})
CREATE (myTweet:Conversation {content: 'PDT2022_Olala'})
CREATE (StefanHajdu)-[:TWEETED]->(myTweet)-[:HAS]->(myHashtag:Hashtag {tag: 'NoWar'})
CREATE (myTweet)-[:RETWEETED]->(ZelenskyTweet)
```

**Kontrola**:

Toto query kontoroluje, či sme naozaj vytvorili nášho autora spolu s tweetom a hashtagom.

```SQL
CALL {
MATCH (zelensky:Author {username: 'ZelenskyyUa'})-[rel:TWEETED]->(ZelenskyTweet:Conversation)<-[reply:REPLIED_TO]-(otherTweet:Conversation)
WITH ZelenskyTweet, otherTweet, reply
RETURN ZelenskyTweet, size(collect(reply)) as cnt
ORDER BY cnt DESC
LIMIT 1
}
MATCH (a:Conversation)-[:RETWEETED]->(ZelenskyTweet)
RETURN a

MATCH (StefanHajdu:Author {username: 'sh00066'})-[:TWEETED]->(myTweet)-[:HAS]->(myHashtag:Hashtag {tag: 'NoWar'})
RETURN *
```

![u3-res.jpg](images/u1_check2.png)

Toto query kontorluje, či sme vytvorili retweet na Zelenskyho tweet. Vidíme, že nami pridaný tweet sa ukázal medzi všetkými tweetami, ktoré retweetujú Zelenskyho tweet.

```SQL
CALL {
    MATCH (zelensky:Author {username: 'ZelenskyyUa'})-[rel:TWEETED]->(ZelenskyTweet:Conversation)<-[reply:REPLIED_TO]-(otherTweet:Conversation)
WITH ZelenskyTweet, otherTweet, reply
RETURN ZelenskyTweet, size(collect(reply)) as cnt
ORDER BY cnt DESC
LIMIT 1
}
MATCH (a:Conversation)-[rel:REPLIED_TO]->(ZelenskyTweet)
RETURN a, rel, ZelenskyTweet
```

![u3-res.jpg](images/u1.png)

## Úloha 2

**Query pre 10 najvačších influencerov podľa počtu retweetov:**

```SQL
MATCH (influencer:Author)-[tweeted:TWEETED]->(tweet:Conversation)<-[retweeted:RETWEETED]-(retweet:Conversation)
WITH influencer, retweet
RETURN influencer, size(collect(retweet)) as retweet_cnt
ORDER BY retweet_cnt DESC
LIMIT 10
```

![u3-res.jpg](images/u2-inf.png)

**Výsledné Query:**

```SQL
CALL {
MATCH (influencer:Author)-[tweeted:TWEETED]->(tweet:Conversation)<-[retweeted:RETWEETED]-(retweet:Conversation)
WITH influencer, retweet
RETURN influencer, size(collect(retweet)) as retweet_cnt
ORDER BY retweet_cnt DESC
LIMIT 10
}

MATCH (influencer)-[:TWEETED]->(tweet:Conversation)
MATCH (tweet)<-[retweeted:RETWEETED]-(otherTweet:Conversation)
RETURN influencer.username, tweet.content, tweet.retweet_count, size(collect(retweeted)) as shit_tweet_cnt
ORDER BY shit_tweet_cnt
LIMIT 20
```

**Výsledok:**

![u3-res.jpg](images/u2-res.png)

## Úloha 3

**Vizualizácia retweet-ovania rovnaných tweetov medzi dvoma autormi:**

```SQL
// najde vsetky retweetnute tweety Mariosom
MATCH (Marios:Author {username: 'Marios59885699'})-[m_tweet:TWEETED]->(MariosTweet:Conversation)-[m_retweet:RETWEETED]->(MariosRetweet:Conversation)

// najde vsetky cesty od ineho autora k tweetom retweetnutych Mariosom
MATCH (likeMarios:Author)-[o_tweet:TWEETED]->(likeMariosTweet:Conversation)-[o_retweet:RETWEETED]->(MariosRetweet)
WHERE Marios <> likeMarios AND likeMarios.username = '03bonbon03'
RETURN likeMarios
```

![u3-res.jpg](images/u3-show.png)

**Výsledné Query:**

```SQL
MATCH (Marios:Author {username: 'Marios59885699'})-[m_tweet:TWEETED]->(MariosTweet:Conversation)-[m_retweet:RETWEETED]->(MariosRetweet:Conversation)
MATCH (likeMarios:Author)-[o_tweet:TWEETED]->(likeMariosTweet:Conversation)-[o_retweet:RETWEETED]->(MariosRetweet)
WHERE Marios <> likeMarios
RETURN likeMarios.username, size(collect(likeMarios.username)) as follower_recommend_cnt
ORDER BY follower_recommend_cnt DESC
LIMIT 10
```

![u3-res.jpg](images/u3-res.png)

## Úloha 4

**Výsledné Query:**

```SQL
MATCH (ua_par:Author {username: 'ua_parliament'}), (nexta:Author {username: 'nexta_tv'})
MATCH paths = allShortestPaths((ua_par)-[r1:TWEETED|RETWEETED|REPLIED_TO|QUOTED*..10]-(nexta))
RETURN paths

MATCH (ua_par:Author {username: 'ua_parliament'}), (nexta:Author {username: 'nexta_tv'})
MATCH paths = allShortestPaths((ua_par)-[*..10]-(nexta))
WHERE all(rel IN relationships(paths) WHERE type(rel) IN ['TWEETED', 'QUOTED', 'REPLIED_TO', 'RETWEETED'])
RETURN paths
```

![u3-res.jpg](images/u4-res.png)

## Úloha 5

**Výsledné Query:**

```SQL
MATCH (ua_par:Author {username: 'ua_parliament'}), (nexta:Author {username: 'nexta_tv'})
MATCH path = shortestPath((ua_par)-[*..10]-(nexta))
WHERE all(rel IN relationships(path) WHERE type(rel) IN ['TWEETED', 'QUOTED', 'REPLIED_TO', 'RETWEETED'])
WITH reduce(output = [], n IN nodes(path) | output + n) as nodesCollection
UNWIND nodesCollection as tweet_nodes
WITH tweet_nodes
WHERE 'Conversation' IN LABELS(tweet_nodes)
MATCH (a:Author)-[tw:TWEETED]->(tweet_nodes)
RETURN a, tw, tweet_nodes
```

![u3-res.jpg](images/u5.png)

## Úloha 6

**Výsledné Query:**

```SQL
CALL {
    MATCH (a:Author)-[t:TWEETED]->(tw:Conversation)-[has:HAS]->(hashtag:Hashtag)
WITH has, hashtag
RETURN hashtag, size(collect(has)) as num_of_usages
ORDER BY num_of_usages DESC
LIMIT 10
}

MATCH (a:Author)-[t:TWEETED]->(tw:Conversation)-[has:HAS]->(hashtag)
WITH a, hashtag, size(collect(t)) as per_user, num_of_usages
ORDER BY per_user DESC
RETURN hashtag.tag as hashtag, collect(a.username)[0] as most_used_by, num_of_usages as total_times_used
```

![u3-res.jpg](images/u6-res.png)
