package parsers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
	"github.com/PuerkitoBio/goquery"
)

type DataInfo struct {
	Name   string `json:"name"`
	Link   string `json:"link"`
	Rating string `json:"rating"`
	Avatar string `json:"avatar"`
}

func LoadAndParse(url string, city string) error {
	resp, err := http.Get(url)
	if err != nil {
		log.Fatal(err)
		return err
	}
	defer resp.Body.Close()

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return err
	}

	doc.Find(".short.shadow.master").Each(func(i int, s *goquery.Selection) {
		// Читаем data-info
		dataInfoRaw, exists := s.Attr("data-info")
		if !exists {
			return
		}

		var info DataInfo
		err := json.Unmarshal([]byte(dataInfoRaw), &info)
		if err != nil {
			return
		}

		name := strings.TrimSpace(info.Name)
		link := "https://kzn.repetitors.info" + info.Link
		avatar := strings.ReplaceAll(info.Avatar, `\/`, `/`)
		rating := info.Rating

		var subject, price string

		level := strings.TrimSpace(
			s.Find(".btn-a.has-icon").First().Text(),
		)

		s.Find(".hide_list_item").EachWithBreak(func(i int, item *goquery.Selection) bool {
			subject = strings.TrimSpace(item.Find(".dt").Text())
			price = strings.TrimSpace(item.Find(".dd").Text())
			return false // только первый элемент
		})

		var rating_float float64
		if info.Rating != "" {
			ratingStr := strings.ReplaceAll(rating, ",", ".")
			rating_float, _ = strconv.ParseFloat(ratingStr, 64)
		}

		teacher := database.Teacher{
			Name:      name,
			Subject:   subject,
			Level:     level,
			Price:     price,
			City:      city,
			Rating:    rating_float,
			AvatarURL: avatar,
			Link:      link,
		}
		database.AddTeacher(teacher)
	})

	return nil
}

func TeacherParser() {
	cities := map[string]string{
		"Адыгея":              "http://adygeya.repetitors.info/repetitor/?nav=page-1-size-",
		"Алтай":               "http://altai.repetitors.info/repetitor/?nav=page-1-size-",
		"Амурская область":    "http://amur.repetitors.info/repetitor/?nav=page-1-size-",
		"Архангельск":         "http://arhangelsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Астрахань":           "http://astrahan.repetitors.info/repetitor/?nav=page-1-size-",
		"Барнаул":             "http://barnaul.repetitors.info/repetitor/?nav=page-1-size-",
		"Белгород":            "http://belgorod.repetitors.info/repetitor/?nav=page-1-size-",
		"Брянск":              "http://bryansk.repetitors.info/repetitor/?nav=page-1-size-",
		"Бурятия":             "http://buryatia.repetitors.info/repetitor/?nav=page-1-size-",
		"Великий Новгород":    "http://vnovgorod.repetitors.info/repetitor/?nav=page-1-size-",
		"Владимир":            "http://vladimir.repetitors.info/repetitor/?nav=page-1-size-",
		"Волгоград":           "http://volgograd.repetitors.info/repetitor/?nav=page-1-size-",
		"Вологда":             "http://vologda.repetitors.info/repetitor/?nav=page-1-size-",
		"Воронеж":             "http://vrn.repetitors.info/repetitor/?nav=page-1-size-",
		"Дагестан":            "http://dagestan.repetitors.info/repetitor/?nav=page-1-size-",
		"Еврейская АО":        "http://birobidzhan.repetitors.info/repetitor/?nav=page-1-size-",
		"Екатеринбург":        "http://ekt.repetitors.info/repetitor/?nav=page-1-size-",
		"Забайкальский край":  "http://zabaikal.repetitors.info/repetitor/?nav=page-1-size-",
		"Иваново":             "http://ivanovo.repetitors.info/repetitor/?nav=page-1-size-",
		"Ингушетия":           "http://ingushetia.repetitors.info/repetitor/?nav=page-1-size-",
		"Иркутск":             "http://irkutsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Кабардино-Балкария":  "http://kbrdnblkr.repetitors.info/repetitor/?nav=page-1-size-",
		"Казань":              "http://kzn.repetitors.info/repetitor/?nav=page-1-size-",
		"Калининград":         "http://kaliningrad.repetitors.info/repetitor/?nav=page-1-size-",
		"Калмыкия":            "http://kalmykia.repetitors.info/repetitor/?nav=page-1-size-",
		"Калуга":              "http://kaluga.repetitors.info/repetitor/?nav=page-1-size-",
		"Камчатский край":     "http://kamchatka.repetitors.info/repetitor/?nav=page-1-size-",
		"Карачаево-Черкесия":  "http://krchvchrks.repetitors.info/repetitor/?nav=page-1-size-",
		"Карелия":             "http://karelia.repetitors.info/repetitor/?nav=page-1-size-",
		"Кемерово":            "http://kemerovo.repetitors.info/repetitor/?nav=page-1-size-",
		"Киров":               "http://kirov.repetitors.info/repetitor/?nav=page-1-size-",
		"Коми":                "http://komi.repetitors.info/repetitor/?nav=page-1-size-",
		"Кострома":            "http://kostroma.repetitors.info/repetitor/?nav=page-1-size-",
		"Краснодар":           "http://ksdr.repetitors.info/repetitor/?nav=page-1-size-",
		"Красноярск":          "http://krsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Крым":                "http://krym.repetitors.info/repetitor/?nav=page-1-size-",
		"Курган":              "http://kurgan.repetitors.info/repetitor/?nav=page-1-size-",
		"Курск":               "http://kursk.repetitors.info/repetitor/?nav=page-1-size-",
		"Липецк":              "http://lipetsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Магадан":             "http://magadan.repetitors.info/repetitor/?nav=page-1-size-",
		"Марий Эл":            "http://marijel.repetitors.info/repetitor/?nav=page-1-size-",
		"Мордовия":            "http://mordovia.repetitors.info/repetitor/?nav=page-1-size-",
		"Москва":              "http://repetitors.info/repetitor/?nav=page-1-size-",
		"Мурманск":            "http://murmansk.repetitors.info/repetitor/?nav=page-1-size-",
		"Ненецкий АО":         "http://narianmar.repetitors.info/repetitor/?nav=page-1-size-",
		"Нижний Новгород":     "http://nnov.repetitors.info/repetitor/?nav=page-1-size-",
		"Новосибирск":         "http://nsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Омск":                "http://omsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Орёл":                "http://orel.repetitors.info/repetitor/?nav=page-1-size-",
		"Оренбург":            "http://orenburg.repetitors.info/repetitor/?nav=page-1-size-",
		"Пенза":               "http://penza.repetitors.info/repetitor/?nav=page-1-size-",
		"Пермь":               "http://prm.repetitors.info/repetitor/?nav=page-1-size-",
		"Приморский край":     "http://primorie.repetitors.info/repetitor/?nav=page-1-size-",
		"Псков":               "http://pskov.repetitors.info/repetitor/?nav=page-1-size-",
		"Ростов-на-Дону":      "http://rnd.repetitors.info/repetitor/?nav=page-1-size-",
		"Рязань":              "http://ryazan.repetitors.info/repetitor/?nav=page-1-size-",
		"Самара":              "http://smr.repetitors.info/repetitor/?nav=page-1-size-",
		"Санкт-Петербург":     "http://spb.repetitors.info/repetitor/?nav=page-1-size-",
		"Саратов":             "http://saratov.repetitors.info/repetitor/?nav=page-1-size-",
		"Северная Осетия":     "http://alania.repetitors.info/repetitor/?nav=page-1-size-",
		"Смоленск":            "http://smolensk.repetitors.info/repetitor/?nav=page-1-size-",
		"Сочи":                "http://sochi.repetitors.info/repetitor/?nav=page-1-size-",
		"Ставрополь":          "http://stavropol.repetitors.info/repetitor/?nav=page-1-size-",
		"Тамбов":              "http://tambov.repetitors.info/repetitor/?nav=page-1-size-",
		"Тверь":               "http://tver.repetitors.info/repetitor/?nav=page-1-size-",
		"Тольятти":            "http://tolyatti.repetitors.info/repetitor/?nav=page-1-size-",
		"Томск":               "http://tomsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Тула":                "http://tula.repetitors.info/repetitor/?nav=page-1-size-",
		"Тыва":                "http://tyva.repetitors.info/repetitor/?nav=page-1-size-",
		"Тюмень":              "http://tyumen.repetitors.info/repetitor/?nav=page-1-size-",
		"Удмуртия":            "http://udmurtia.repetitors.info/repetitor/?nav=page-1-size-",
		"Ульяновск":           "http://ulyanovsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Уфа":                 "http://ufa.repetitors.info/repetitor/?nav=page-1-size-",
		"Хабаровск":           "http://habarovsk.repetitors.info/repetitor/?nav=page-1-size-",
		"Хакасия":             "http://hakasia.repetitors.info/repetitor/?nav=page-1-size-",
		"Ханты-Мансийский АО": "http://yugra.repetitors.info/repetitor/?nav=page-1-size-",
		"Челябинск":           "http://chel.repetitors.info/repetitor/?nav=page-1-size-",
		"Чечня":               "http://chechnya.repetitors.info/repetitor/?nav=page-1-size-",
		"Чувашия":             "http://chuvashia.repetitors.info/repetitor/?nav=page-1-size-",
		"Чукотский АО":        "http://chukotka.repetitors.info/repetitor/?nav=page-1-size-",
		"Южно-Сахалинск":      "http://sahalin.repetitors.info/repetitor/?nav=page-1-size-",
		"Якутия":              "http://yakutia.repetitors.info/repetitor/?nav=page-1-size-",
		"Ямало-Ненецкий АО":   "http://yanao.repetitors.info/repetitor/?nav=page-1-size-",
		"Ярославль":           "http://yar.repetitors.info/repetitor/?nav=page-1-size-",
	}

	for city, url := range cities {
		fmt.Println("Парсим город:", city)

		err := LoadAndParse(url, city)
		if err != nil {
			log.Println("Ошибка при загрузке города", city, ":", err)
			continue
		}
	}
}

func StartTeacherParserTicker(t int) {
	interval := time.Duration(t) * time.Hour

	go TeacherParser()

	ticker := time.NewTicker(interval)

	go func() {
		for {
			select {
			case <-ticker.C:
				TeacherParser()
			}
		}
	}()
}
