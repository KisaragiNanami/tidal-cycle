import { getCollection } from "astro:content";
import rss from "@astrojs/rss";

export const prerender = true;

export async function GET(context: any) {
  const posts = await getCollection("blog");
  const sortedPosts = posts.sort(
    (a: any, b: any) =>
      new Date(b.data.pubDate).getTime() - new Date(a.data.pubDate).getTime(),
  );
  return rss({
    title: "七海ノ心象素描",
    description: "Cross+Channel",
    site: context.site,
    items: sortedPosts.map((blog: any) => ({
      ...blog.data,
      link: `/blog/${blog.slug}/`,
    })),
  });
}
