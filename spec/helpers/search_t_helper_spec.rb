# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "search_t", type: :helper do
  it "should find text in text" do
    helper.search_t(["asdasdasdasd"], 'asd').should be_true
    helper.search_t(["asdasdasdasd"], 'aSd').should be_true
    helper.search_t(["asdasdasdasd"], 'Asd').should be_true
  end
  it "should find text in html" do
    a = <<-eos 
<p> </p><h2 style="text-align: center;">“There Is No Hierarchy of Oppressions”&nbsp;</h2><h3 style="text-align: center;">Audre Lorde</h3> <blockquote>“I was born Black, and a woman. I am trying to become the strongest person I can become to live the life I have been given and to help effect change toward a liveable future for this earth and for my children. As a Black, lesbian, feminist, socialist, poet, mother of two including one boy and a member of an interracial couple, I usually find myself part of some group in which the majority defines me as deviant, difficult, inferior or just plain "wrong."<br><span style="line-height: 1.45em;"><br>From my membership in all of these groups I have learned that oppression and the intolerance of difference come in all shapes and sexes and colors and sexualities; and that among those of us who share the goals of liberation and a workable future for our children, there can be no hierarchies of oppression. I have learned that sexism and heterosexism both arise from the same source as racism.<br></span><span style="line-height: 1.45em;"><br>"Oh," says a voice from the Black community, "but being Black is NORMAL!" Well, I and many Black people of my age can remember grimly the days when it didn't used to be!<br></span><span style="line-height: 1.45em;"><br>I simply do not believe that one aspect of myself can possibly profit from the oppression of any other part of my identity. I know that my people cannot possibly profit from the oppression of any other group which seeks the right to peaceful existence. Rather, we diminish ourselves by denying to others what we have shed blood to obtain for our children. And those children need to learn that they do not have to become like each other in order to work together for a future they will all share.<br></span><span style="line-height: 1.45em;"><br>Within the lesbian community I am Black, and within the Black community I am a lesbian. Any attack against Black people is a lesbian and gay issue, because I and thousands of other Black women are part of the lesbian community. Any attack against lesbians and gays is a Black issue, because thousands of lesbians and gay men are Black. There is no hierarchy of oppression.<br></span><span style="line-height: 1.45em;"><br>I cannot afford the luxury of fighting one form of oppression only. I cannot afford to believe that freedom from intolerance is the right of only one particular group. And I cannot afford to choose between the fronts upon which I must battle these forces of discrimination, wherever they appear to destroy me. And when they appear to destroy me, it will not be long before they appear to destroy you.”</span></blockquote> <p></p> <pre>From Homophobia and Education New York: Council on Interracial Books for Children, 1983</pre> <br><p></p>
eos
    helper.search_t([a], 'Black').should be_true
    helper.search_t([a], 'black').should be_true
    helper.search_t([a], 'bLack').should be_true
  end

  it "should find in array" do
    helper.search_t(['checkbox', 'checkbox', 'number'], 'a').should be_false
  end
end

