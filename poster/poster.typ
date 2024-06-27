// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}


#let poster(
  // The poster's size.
  size: "'36x24' or '48x36''",

  // The poster's title.
  title: "Paper Title",

  // A string of author names.
  authors: "Author Names (separated by commas)",

  // Department name.
  departments: "Department Name",

  // University logo.
  univ_logo: "Logo Path",

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
  footer_text: "Footer Text",

  // Any URL, like a link to the conference website.
  footer_url: "Footer URL",

  // Email IDs of the authors.
  footer_email_ids: "Email IDs (separated by commas)",

  // Color of the footer.
  footer_color: "Hex Color Code",
  
  // Text color of the footer.
  footer_text_color: "Hex Color Code",

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  keywords: (),

  // Number of columns in the poster.
  num_columns: "3",

  // University logo's scale (in %).
  univ_logo_scale: "50",

  // University logo's column size (in in).
  univ_logo_column_size: "10",

  // Title and authors' column size (in in).
  title_column_size: "20",

  // Poster title's font size (in pt).
  title_font_size: "42",

  // Authors' font size (in pt).
  authors_font_size: "34",

  // Footer's URL and email font size (in pt).
  footer_url_font_size: "28",

  // Footer's text font size (in pt).
  footer_text_font_size: "35",

  // The poster's content.
  body
) = {
  // Set the body font.
  set text(font: "STIX Two Text", size: 16pt)
  let sizes = size.split("x")
  let width = int(sizes.at(0)) * 1in
  let height = int(sizes.at(1)) * 1in
  univ_logo_scale = int(univ_logo_scale) * 1%
  title_font_size = int(title_font_size) * 1pt
  authors_font_size = int(authors_font_size) * 1pt
  num_columns = int(num_columns)
  univ_logo_column_size = int(univ_logo_column_size) * 1in
  title_column_size = int(title_column_size) * 1in
  footer_url_font_size = int(footer_url_font_size) * 1pt
  footer_text_font_size = int(footer_text_font_size) * 1pt

  // Configure the page.
  // This poster defaults to 36in x 24in.
  set page(
    width: width,
    height: height,
    margin: 
      (top: 1in, left: 2in, right: 2in, bottom: 2in),
    footer: [
      #set align(right)
      #set text(32pt, white)
      #block(
        fill: rgb(228,51,44),
        width: 100%,
        inset: 20pt,
        radius: 10pt,
        [
          //#text(font: "Courier", size: footer_url_font_size, footer_url) 
          //#h(1fr) 
          #text(size: footer_text_font_size, smallcaps(footer_text)) 
          #h(1fr) 
          #text(font: "Courier", size: footer_url_font_size, footer_email_ids)
        ]
      )
    ]
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  //set heading(numbering: "I.A.1.")
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(24pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      #set align(center)
      #set text({ 32pt })
      #show: smallcaps
      #v(50pt, weak: true)
      #if it.numbering != none {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(35.75pt, weak: true)
      #line(length: 100%)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set text(style: "italic")
      #v(32pt, weak: true)
      #if it.numbering != none {
        numbering("i.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering("1)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  })

  // Arranging the logo, title, authors, and department in the header.
  align(center,
    grid(
      rows: 2,
      columns: (title_column_size, univ_logo_column_size),
      column-gutter: 0pt,
      row-gutter: 50pt,
      text(title_font_size, title + "\n\n") + 
      text(authors_font_size, emph("Team Oldlace\n")) + 
      text(authors_font_size, emph(authors) + 
          "   (" + departments + ") "),
      image(univ_logo, width: univ_logo_scale),
    )
  )

  // Start three column mode and configure paragraph properties.
  show: columns.with(num_columns, gutter: 64pt)
  set par(justify: true, first-line-indent: 0em)
  show par: set block(spacing: 0.65em)

  // Display the keywords.
  if keywords != () [
      #set text(24pt, weight: 400)
      #show "Keywords": smallcaps
      *Keywords* --- #keywords.join(", ")
  ]

  // Display the poster's contents.
  body
}
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => poster(
   title: [Visualizing Billion-Dollar Disasters in the USA \(1980–2024)], 
  // TODO: use Quarto's normalized metadata.
   authors: [Oh Jia Wei Darien, Peter Febrianto Afandy, Quek Joo Wee, Desmond Loy Yong Kiat, \
Rene Low Yi Xuan, Phileo Teo Weihan], 
   departments: [SIT-UoG Computing Science], 
   size: "33x23", 

  // Institution logo.
   univ_logo: "images/sit-logo.png", 

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
   footer_text: [CSC3107 Project], 

  // Any URL, like a link to the conference website.
  

  // Emails of the authors.
   footer_email_ids: [2200607\@sit.singaporetech.edu.sg, 2200959\@sit.singaporetech.edu.sg, 2201046\@sit.singaporetech.edu.sg, 2201435\@sit.singaporetech.edu.sg, 2202620\@sit.singaporetech.edu.sg, 2203179\@sit.singaporetech.edu.sg], 

  // Color of the footer.
  
  
  // Text color of the footer.
  

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  

  // Number of columns in the poster.
  

  // University logo's scale (in %).
  

  // University logo's column size (in in).
  

  // Title and authors' column size (in in).
  

  // Poster title's font size (in pt).
  

  // Authors' font size (in pt).
  

  // Footer's URL and email font size (in pt).
  

  // Footer's text font size (in pt).
  

  doc,
)


= Introduction
<introduction>
\<some intro and info on disaster relief fund being drained..\>

To highlight the need for enhanced disaster preparedness in the USA, Dottle and Kaufman#footnote[Dottle, R., & Kaufman, L. \(2023). Climate Disasters Drain US Emergency Fund, Adding to Government Shutdown Risk. Retrieved from https:\/\/www.bloomberg.com/graphics/2023-fema-disaster-relief-fund-extreme-weather-climate-aid/] presented a combined plot visualizing the total estimated costs by disaster type and the frequency of such events from 1980 to 2023. The plot demonstrated the increased frequency of various types of disasters over the years, likely driven by factors such as climate change, along with their escalating financial impact and costs. Coupled with the depletion of the country’s Disaster Relief Fund \(DRF), this elucidates the dire need for proactive preparations and mitigations to address the growing threat of such disasters effectively.

= Previous Visualization
<previous-visualization>
#block[
#block[
#figure([
#box(width: 100%,image("images/bb_bdd_cropped.png"))
], caption: figure.caption(
position: bottom, 
[
Frequency and Estimated Costs of Billion-Dollar Disasters in the USA by year, published by Bloomberg.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-previous-visual-on-poster>


]
]
= Strengths
<strengths>
- The graph includes a #emph[dual-axis] representation of the frequency and costs of billion-dollar disasters, providing a comprehensive overview of the data with the use of stacked areas and bars.
- It includes #emph[annotated descriptions] on certain data points, enhancing the interpretability of the visualisation.
- The timeline shows #emph[clear trends] over the decades, highlighting the increasing frequency and costs of natural disasters.

= Suggested Improvements
<suggested-improvements>
+ #emph[Split the visualisation into two separate plots] to better highlight the trends in frequency and costs of billion-dollar disasters.
+ #emph[Enhance the color palette] to improve readability and distinguish between different disaster types.
+ #emph[Group disaster types] together to provide a clearer overview of the data.

= Implementation
<implementation>
== Data
<data>
- Frequency and estimated cost for each disaster type is obtained from the National Centers for Environmental Information \(NCEI). #footnote[#link("https://www.ncei.noaa.gov/access/billions/time-series");]
- Consolidated data with NCEI USA to obtain more detailed information on each disaster specific to the United States.\[^ncei\_usa\]

\[^ncei\_usa\] : #link("https://www.ncei.noaa.gov/access/billions/state-summary/US")

== Software
<software>
We used the Quarto publication framework and the R programming language, along with the following third-party packages:

- #emph[tidyverse] for data transformation, including #emph[ggplot2] for visualization based on the grammar of graphics
- #emph[knitr] for dynamic document generation

= Further Suggestions for Interactivity
<further-suggestions-for-interactivity>
Since the visualization is intended for a poster, we could include features such as #emph[hover-over tooltips] to display detailed information, #emph[interactive legends] where users could click to highlight specific disaster types and #emph[zoom and pan] to allow users to closely examine selected areas of the visualisation. This enhances user engagement and provides a more interactive experience.

= Improved Visualization
<improved-visualization>
#block[
#block[
#figure([
#box(width: 720.0pt, image("poster_files/figure-typst/fig-improved-visual-on-poster-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Revised Visualisation of Frequency and Estimated Costs of Billion-Dollar Disasters in the USA by year.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-improved-visual-on-poster>


]
]
= Conclusion
<conclusion>
…
