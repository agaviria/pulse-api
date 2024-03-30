CREATE EXTENSION ulid;

/* `user` is reserved keyword in postgres.
   using "user" with double quotes requires string escaping all the time.
   `user_` is the current best option.
*/
CREATE TABLE if NOT EXISTS user_ (
   id ulid NOT NULL DEFAULT gen_ulid() PRIMARY KEY,
   created_at TIMESTAMP WITH TIME ZONE NOT NULL,
   updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
   email TEXT NOT NULL UNIQUE,
   name TEXT,
   full_name TEXT
);

