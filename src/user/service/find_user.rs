use uuid::Uuid;

use super::Service;
use crate::{errors::Error, user::entities};

impl Service {
    pub async fn find_user(&self, id: Uuid) -> Result<entities::User, Error> {
        let user = self.repo.find_user_by_id(&self.db, id).await?;

        Ok(user)
    }
}
