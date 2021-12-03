package main

import (
	"github.com/PuerkitoBio/goquery"
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
	"log"
	"net/http"
	"strconv"
)

func main() {
	link := "https://github.com/KireyevK/Andersen"
	token := "TOKEN"
	branch := "/tree/main/"
	//run bot
	//bot, err := tgbotapi.NewBotAPI(os.Getenv("TELEGRAM_APITOKEN"))
	bot, err := tgbotapi.NewBotAPI(token)
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true

	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message == nil { // ignore any non-Message Updates
			continue
		}

		if !update.Message.IsCommand() { // ignore any non-command Messages
			continue
		}

		log.Printf("[%s] %s", update.Message.From.UserName, update.Message.Text)

		msg := tgbotapi.NewMessage(update.Message.Chat.ID, update.Message.Text)
		//		msg.ReplyToMessageID = update.Message.MessageID
		msg.Text = "I don't know that command "

		switch update.Message.Command() {
		case "help":
			msg.Text = "Menu:\n/git        Get link to repo\n/tasks   Get numbered list of tasks"
		case "git":
			msg.Text = link
		case "tasks":
			arr := SearchDir(link)
			var str string
			for i := 0; i < len(arr); i++ {
				str = str + "/task_" + strconv.Itoa(i+1) + " - " + arr[i] + "\n"
			}
			msg.Text = str
		default:
			if update.Message.Command()[0:5] == "task_" {
				n, err := strconv.Atoi(update.Message.Command()[5:])
				arr := SearchDir(link)
				if err == nil && 1 <= n && n <= len(arr) {
					msg.Text = link + branch + arr[n-1]
				}
			}
		}

		if _, err := bot.Send(msg); err != nil {
			log.Panic(err)
		}
	}
}

func SearchDir(addr string) []string {
	// Request the HTML page.
	res, err := http.Get(addr)
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Fatalf("status code error: %d %s", res.StatusCode, res.Status)
	}
	// Load the HTML document
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		log.Fatal(err)
	}
	var arr []string
	// Find the review items
	doc.Find("a.js-navigation-open.Link--primary").Each(func(i int, s *goquery.Selection) {
		// For each item found, get the title
		if s.Text() != "README.md" {
			arr = append(arr, s.Text())
		}
	})
	return arr
}
