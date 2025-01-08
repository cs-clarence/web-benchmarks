use axum::{extract::State, http::StatusCode, response::IntoResponse, routing::get, Json, Router};
use serde::Serialize;
use sqlx::{prelude::FromRow, PgPool};
use tokio::signal;

#[derive(Serialize, FromRow)]
#[serde(rename_all = "camelCase")]
struct User {
    user_name: String,
    email_address: String,
    first_name: String,
    last_name: String,
}

async fn get_users(State(pool): State<PgPool>) -> impl IntoResponse {
    let users = sqlx::query_as::<_, User>(
        r#"
        SELECT user_name, email_address, first_name, last_name
        FROM users
        "#,
    )
    .fetch_all(&pool)
    .await;

    match users {
        Ok(users) => Json(users).into_response(),
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}

#[tokio::main]
async fn main() -> eyre::Result<()> {
    let username = std::env::var("DATABASE_USERNAME").unwrap_or_else(|_| "root".to_string());
    let password = std::env::var("DATABASE_PASSWORD").unwrap_or_else(|_| "password".to_string());
    let db_host = std::env::var("DATABASE_HOSTNAME").unwrap_or_else(|_| "database".to_string());
    let db_name = std::env::var("DATABASE_NAME").unwrap_or_else(|_| "web_benchmarks".to_string());
    let db_port = std::env::var("DATABASE_PORT").unwrap_or_else(|_| "5432".to_string());
    let database_url = format!("postgres://{username}:{password}@{db_host}:{db_port}/{db_name}");
    let pool = PgPool::connect(&database_url).await?;

    let app = Router::new()
        .route("/users", get(get_users))
        .with_state(pool);

    let addr = tokio::net::TcpListener::bind("0.0.0.0:80").await?;

    axum::serve(addr, app)
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    Ok(())
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
}