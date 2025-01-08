package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
	_ "github.com/lib/pq" // PostgreSQL driver
)

type User struct {
	UserName     string `json:"userName"`
	EmailAddress string `json:"emailAddress"`
	FirstName    string `json:"firstName"`
	LastName     string `json:"lastName"`
}

func createInternalServerError(err error) map[string]string {
	return map[string]string{"error": "Internal Server Error", "message": err.Error()}
}

func getUsers(db *sql.DB) echo.HandlerFunc {
	return func(c echo.Context) error {
		rows, err := db.Query(`
            SELECT user_name, email_address, first_name, last_name
            FROM users
        `)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, createInternalServerError(err))
		}
		defer rows.Close()

		var users []User
		for rows.Next() {
			var user User
			if err := rows.Scan(&user.UserName, &user.EmailAddress, &user.FirstName, &user.LastName); err != nil {
				return c.JSON(http.StatusInternalServerError, createInternalServerError(err))
			}
			users = append(users, user)
		}

		return c.JSON(http.StatusOK, users)
	}
}

func main() {
	dbHost := os.Getenv("DATABASE_HOSTNAME")
	dbUsername := os.Getenv("DATABASE_USERNAME")
	dbPassword := os.Getenv("DATABASE_PASSWORD")
	dbName := os.Getenv("DATABASE_NAME")
	dbPort := os.Getenv("DATABASE_PORT")
	dbUrl := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", dbUsername, dbPassword, dbHost, dbPort, dbName)
	db, err := sql.Open("postgres", dbUrl) // Replace with your DB URL
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}
	defer db.Close()

	e := echo.New()
	e.GET("/users", getUsers(db))

	log.Println("Server started at http://0.0.0.0:80")
	if err := e.Start("0.0.0.0:80"); err != nil {
		log.Fatalf("Failed to start the server: %v", err)
	}
}
