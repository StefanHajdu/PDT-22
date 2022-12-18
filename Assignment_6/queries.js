db.ref_testing.aggregate([
  {
    $lookup: {
      from: "ref_testing",
      localField: "_id",
      foreignField: "Friends",
      as: "Friends_name",
    },
  },
]);

db.friend_v2.aggregate([
  {
    $lookup: {
      from: "friend_v2",
      localField: "_id",
      foreignField: "Friends.id",
      as: "Friends_name",
    },
  },
]);

db.tweets_all.aggregate([
  {
    $project: {
      created_at: {
        $dateFromString: {
          dateString: "$metadata.created_at",
          format: "%Y-%m-%dT%H:%M:%S%z",
        },
      },
    },
  },
]);

db.tweets_all.aggregate([
  { $match: { "author.username": "Newnews_eu" } },
  {
    $project: {
      "author.username": 1,
      "metadata.created_at": 1,
      "metadata.content": 1,
    },
  },
]);

db.tweets_all.aggregate([
  { $match: { "author.username": "Newnews_eu" } },
  {
    $project: {
      "author.username": 1,
      "metadata.content": 1,
      created_at: {
        $dateFromString: {
          dateString: "$metadata.created_at",
          format: "%Y-%m-%dT%H:%M:%S%z",
        },
      },
    },
  },
  { $sort: { created_at: -1 } },
  { $limit: 10 },
]);

db.tweets_all.aggregate([
  {
    $match: {
      "referencies.reference_id": "1496830803736731649",
      "referencies.type": "retweeted",
    },
  },
  {
    $project: {
      "author.username": 1,
      "metadata.content": 1,
      created_at: {
        $dateFromString: {
          dateString: "$metadata.created_at",
          format: "%Y-%m-%dT%H:%M:%S%z",
        },
      },
    },
  },
  { $sort: { created_at: -1 } },
  { $limit: 10 },
]);

db.tweets_all.aggregate([
  {
    $lookup: {
      from: "tweets_all",
      localField: "_id",
      foreignField: "referencies.reference_id",
      as: "Full_Refs",
    },
  },
  { $limit: 2 },
]);
