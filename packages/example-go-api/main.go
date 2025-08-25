package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
)

func main() {
	// Initialize Firebase with emulator support
	ctx := context.Background()
	
	// Check if we're in development mode
	if os.Getenv("USE_FIREBASE_EMULATOR") == "true" {
		os.Setenv("FIRESTORE_EMULATOR_HOST", "localhost:5172")
		os.Setenv("FIREBASE_AUTH_EMULATOR_HOST", "localhost:5171")
		os.Setenv("FIREBASE_STORAGE_EMULATOR_HOST", "localhost:5175")
	}

	// Initialize Firebase App
	opt := option.WithoutAuthentication()
	config := &firebase.Config{
		ProjectID: os.Getenv("FIREBASE_PROJECT_ID"),
	}
	
	app, err := firebase.NewApp(ctx, config, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	// Initialize Firestore client
	firestoreClient, err := app.Firestore(ctx)
	if err != nil {
		log.Fatalf("error getting Firestore client: %v\n", err)
	}
	defer firestoreClient.Close()

	// Initialize Auth client
	authClient, err := app.Auth(ctx)
	if err != nil {
		log.Fatalf("error getting Auth client: %v\n", err)
	}

	// Set up HTTP handlers
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/test-firestore", testFirestoreHandler(firestoreClient))
	http.HandleFunc("/test-auth", testAuthHandler(authClient))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server starting on port %s\n", port)
	fmt.Println("Firebase Emulator Integration:")
	fmt.Printf("- Firestore: %s\n", os.Getenv("FIRESTORE_EMULATOR_HOST"))
	fmt.Printf("- Auth: %s\n", os.Getenv("FIREBASE_AUTH_EMULATOR_HOST"))
	fmt.Printf("- Storage: %s\n", os.Getenv("FIREBASE_STORAGE_EMULATOR_HOST"))
	
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func testFirestoreHandler(client *firestore.Client) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		
		// Test Firestore connection
		doc := client.Collection("test").Doc("test-doc")
		_, err := doc.Set(ctx, map[string]interface{}{
			"test": "data",
			"timestamp": firestore.ServerTimestamp,
		})
		
		if err != nil {
			http.Error(w, fmt.Sprintf("Firestore error: %v", err), http.StatusInternalServerError)
			return
		}
		
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Firestore connection successful"))
	}
}

func testAuthHandler(client *auth.Client) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		
		// List users (will be empty or have seed data)
		iter := client.Users(ctx, "")
		count := 0
		for {
			_, err := iter.Next()
			if err != nil {
				break
			}
			count++
		}
		
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(fmt.Sprintf("Auth connection successful. Users found: %d", count)))
	}
}