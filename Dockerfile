FROM mcr.microsoft.com/dotnet/aspnet:3.1-focal AS base
WORKDIR /app
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
RUN sudo apt install libc6-dev && sudo apt install libgdiplus


# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:3.1-focal AS build
WORKDIR /src
COPY ["src/Kaptcha.NET/Kaptcha.NET.csproj", "src/Kaptcha.NET/"]
RUN dotnet restore "src/Kaptcha.NET/Kaptcha.NET.csproj"
COPY . .
WORKDIR "/src/src/Kaptcha.NET"
RUN dotnet build "Kaptcha.NET.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Kaptcha.NET.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Kaptcha.NET.dll"]