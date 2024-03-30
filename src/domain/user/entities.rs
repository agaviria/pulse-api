use sqlx::Row;

use frunk::LabelledGeneric;

use crate::{
    relay::Base64Cursor,
    scalar::{self, Time, Ulid},
};

#[derive(Debug, Clone, LabelledGeneric)]
pub struct User {
    pub id: Ulid,
    pub created_at: Time,
    pub updated_at: Time,
    pub name: String,
    pub email: String,
    pub full_name: Option<String>,
}

impl<'r> sqlx::FromRow<'r, sqlx::postgres::PgRow> for User {
    fn from_row(row: &'r sqlx::postgres::PgRow) -> Result<Self, sqlx::Error> {
        let id: String = row.try_get("id")?;
        let created_at: Time = row.try_get("created_at")?;
        let updated_at: Time = row.try_get("updated_at")?;
        let name: String = row.try_get("name")?;
        let email: String = row.try_get("email")?;
        let full_name: Option<String> = row.try_get("full_name")?;

        Ok(Self {
            id: id.parse().expect("failed to parse Id"),
            created_at,
            updated_at,
            name,
            email,
            full_name,
        })
    }
}

#[derive(Debug, LabelledGeneric)]
pub struct UserEdge {
    pub node: User,
    pub cursor: String,
}

impl From<User> for UserEdge {
    fn from(user: User) -> Self {
        let cursor = Base64Cursor::new(scalar::uid::Ulid(*user.id)).encode();
        Self { node: user, cursor }
    }
}

#[derive(Debug, LabelledGeneric)]
pub struct PageInfo {
    pub end_cursor: Option<String>,
    pub has_next_page: bool,
    pub start_cursor: Option<String>,
    pub has_previous_page: bool,
}
