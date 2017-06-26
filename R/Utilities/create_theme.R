
                  #(yellow, dark red, bright red, black-ish)
iprt_palette <- c("#faeea2", "#961d12", "#222222", "#444F93", "#B61914", "#777777", "#706E00" ) 

iprt_theme <-
  ggplot2::theme(plot.title = element_text(face = 2, size = 18, hjust = 0,
                                           colour = iprt_palette[4]),
                 axis.title = element_text(colour = iprt_palette[4],
                                           face = 2, size = 14),
                 axis.text = element_text(colour = iprt_palette[4],
                                          size = 12),
                 axis.text.x = element_text(hjust = 1, vjust = 1,
                                            angle = 45),
                 strip.background =
                   element_rect(iprt_palette[4]),
                 strip.text = element_text(face = "bold", colour = "white",
                                           size = rel(1.2), vjust = 0.5),
                 panel.background =
                   element_rect(fill = paste0(iprt_palette[1], 75)),
                 panel.grid.minor = element_blank(),
                 panel.grid.major.x = element_blank(),
                 panel.grid.major.y = element_line(colour = "white",
                                                   size = 1))


